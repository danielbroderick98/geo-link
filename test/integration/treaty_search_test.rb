require "test_helper"

class TreatySearchTest < ActionDispatch::IntegrationTest
  setup do
    # Keep the search examples separate from the shared fixtures used by other tests.
    Treaty.destroy_all
    @older = Treaty.create!(name: "Trade accord", status: "Signed", date_signed: "2020-01-01")
    @newer = Treaty.create!(name: "Trade framework", status: "Signed", date_signed: "2024-12-31")
    @draft = Treaty.create!(name: "Trade proposal", status: "Draft", date_signed: "2023-04-10")
    @climate = Treaty.create!(name: "Climate agreement", status: "Signed", date_signed: "2022-06-15")
    @undated = Treaty.create!(name: "Trade archive", status: "Signed")
  end

  test "the public directory includes undated treaties and participant links" do
    @older.countries << countries(:one)

    get user_treaties_path

    assert_response :success
    assert_treaty_names @climate.name, @older.name, @undated.name, @newer.name, @draft.name
    assert_select "tbody a[href=?]", user_country_path(countries(:one))
    assert_select "tbody a[href=?]", user_treaty_path(@older)
  end

  test "name searching ignores case and surrounding spaces" do
    get user_treaties_path, params: { q: { name_i_cont: "  FRAMEWORK  " } }

    assert_response :success
    assert_treaty_names @newer.name
    assert_select "input[name='q[name_i_cont]'][value='FRAMEWORK']"
  end

  test "status searching uses the exact saved status" do
    get user_treaties_path, params: { q: { status_eq: "Draft" } }

    assert_response :success
    assert_treaty_names @draft.name
  end

  test "a saved status with surrounding spaces still matches exactly" do
    # Status is a free-text admin field, so older records can contain surrounding spaces.
    @older.update!(status: " Signed ")

    get user_treaties_path, params: { q: { status_eq: " Signed " } }

    assert_response :success
    assert_treaty_names @older.name
  end

  test "name status and inclusive dates work together" do
    # Both boundary dates should be included, while the draft and undated records are excluded.
    get user_treaties_path, params: { q: {
      name_i_cont: "trade", status_eq: "Signed",
      date_signed_gteq: "2020-01-01", date_signed_lteq: "2024-12-31", s: "date_signed desc"
    } }

    assert_response :success
    assert_treaty_names @newer.name, @older.name
    assert_select "option[value='date_signed desc'][selected]"
    assert_select "input[name='q[date_signed_gteq]'][value='2020-01-01']"
  end

  test "each date boundary can be used on its own" do
    get user_treaties_path, params: { q: { date_signed_gteq: "2024-12-31" } }
    assert_treaty_names @newer.name

    get user_treaties_path, params: { q: { date_signed_lteq: "2020-01-01" } }
    assert_treaty_names @older.name
  end

  test "signing dates can be sorted oldest first" do
    get user_treaties_path, params: { q: { date_signed_gteq: "2020-01-01", s: "date_signed asc" } }

    assert_response :success
    assert_treaty_names @older.name, @climate.name, @draft.name, @newer.name
  end

  test "old directory links still apply their name and status filters" do
    get user_treaties_path, params: { query: "framework", status: "Signed" }

    assert_response :success
    assert_treaty_names @newer.name
  end

  test "wildcard characters in treaty names are treated as text" do
    literal = Treaty.create!(name: "Trade 50%_agreement", status: "Signed")
    Treaty.create!(name: "Trade 500Xagreement", status: "Signed")

    get user_treaties_path, params: { q: { name_i_cont: "50%_" } }

    assert_response :success
    assert_treaty_names literal.name
  end

  test "unrecognised search fields and sort values are ignored" do
    get user_treaties_path, params: { q: {
      name_i_cont: "framework", description_cont: "missing",
      countries_name_cont: "missing", m: "or", s: "description desc"
    } }

    assert_response :success
    assert_treaty_names @newer.name
    assert_equal %w[name status date_signed], Treaty.ransackable_attributes
    assert_empty Treaty.ransackable_associations
  end

  test "invalid and reversed dates show a useful error" do
    get user_treaties_path, params: { q: { date_signed_gteq: "2024-02-30" } }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /Enter a valid signing date from/
    assert_select "tbody", count: 0

    get user_treaties_path, params: { q: {
      date_signed_gteq: "2025-01-01", date_signed_lteq: "2020-01-01"
    } }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /must be on or after/
  end

  test "an empty search result offers a way back to all treaties" do
    get user_treaties_path, params: { q: { name_i_cont: "missing agreement" } }

    assert_response :success
    assert_select "h3", text: "No matching treaties"
    assert_select "a[href=?]", user_treaties_path, text: "Show all treaties"
  end

  private

  def assert_treaty_names(*expected)
    # Read only the name column so detail links do not count each treaty twice.
    assert_select "tbody th a" do |links|
      assert_equal expected, links.map { |link| link.text.strip }
    end
  end
end
