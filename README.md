# Geo Link

Geo Link is a cloud application being developed as an academic project. This repository will contain the application source code, documentation, automated tests, and CI/CD workflows.

> **Project status:** Initial planning and repository setup. Application development and cloud deployment are pending.

## Project Overview

The project will demonstrate the design, development, testing, and deployment of a working cloud application.

The detailed application purpose, intended users, and feature list will be documented as the requirements are finalised.

## Project Objectives

- Develop the functionality defined in the project brief.
- Deploy the application to a suitable public cloud platform.
- Provide a public HTTPS URL where the application can be assessed.
- Automate meaningful checks and testing through a CI/CD pipeline.
- Verify that required features work in the deployed environment.
- Document deployment, configuration, and recovery procedures.

## Planned Features

The feature list will be added once the application requirements are confirmed.

## Technology Stack

| Component       | Technology                |
| --------------- | ------------------------- |
| Frontend        | To be confirmed           |
| Backend         | To be confirmed           |
| Database        | To be confirmed           |
| Cloud hosting   | To be confirmed           |
| Version control | Git and GitHub            |
| CI/CD           | GitHub Actions — proposed |
| Testing tools   | To be confirmed           |

## Planned CI/CD Strategy

The intended release process is:

1. Develop changes on a feature branch.
2. Open a pull request.
3. Run automated code checks, tests, and a production build.
4. Review and merge passing changes into `main`.
5. Verify the merged version and deploy it to the cloud.
6. Run checks against the deployed application.
7. Record the release result and investigate any failures.

Deployment will depend on successful required checks. The exact workflow will be documented as it is implemented.

## Deployment

**Live application:** Not yet deployed.

The deployment documentation will include:

- The selected cloud platform and architecture.
- Required configuration and environment variables.
- Database setup and migration instructions.
- Deployment and post-deployment verification steps.
- Backup and recovery procedures.
- Instructions for restoring a previous working release.

Separate staging and production environments will be considered according to project requirements and budget.

## Testing Strategy

Testing will focus on the application's required functionality and important user journeys.

Planned checks include:

- Unit tests for key application logic.
- Integration tests for backend and database interactions.
- Browser tests for essential user journeys.
- Production build verification.
- Checks against the deployed application.

Test commands and results will be added when the application and testing tools are available.

## Local Development

Local setup instructions will be added once the technology stack is confirmed.

These instructions will cover prerequisites, dependency installation, environment configuration, database setup, and how to run the application and tests.

## Configuration and Secrets

Sensitive credentials must not be committed to this repository.

Required environment variables will be documented using an example configuration file containing placeholder values. Deployment credentials will be stored in the appropriate protected secret settings.

## Project Roadmap

- [x] Begin project planning.
- [ ] Confirm application requirements and features.
- [ ] Select the technology stack and cloud platform.
- [ ] Develop an initial working application.
- [ ] Deploy the initial version to the cloud.
- [ ] Implement automated tests and CI checks.
- [ ] Configure deployment after successful checks.
- [ ] Add post-deployment verification.
- [ ] Test recovery and rollback procedures.
- [ ] Verify all required features at the public URL.
- [ ] Complete documentation and assessment evidence.

## Assessment Evidence

Evidence will be collected throughout development, including:

- A cloud architecture diagram.
- CI/CD workflow configuration.
- Successful test and deployment runs.
- A demonstration that failing checks prevent deployment.
- Verification of required features through the public URL.
- A demonstration of the recovery process.

## Academic Context

This repository supports an academic cloud application project. CI/CD and deployment account for 20% of the project marks.

The deployment objective is to provide a working application on a suitable public cloud, supported by a reliable, documented CI/CD strategy.

