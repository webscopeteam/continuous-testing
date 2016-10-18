# Continuous Testing

This repo contain the required files for a Bitbucket / Pantheon / Codeship continuous testing setup.

## Basic flow
1. Developer commits code to Pantheon branch
2. Pantheon Quicksilver webhook fires -> Codeship build is run via Codeships api_driver
3. Codeship runs tests and notifies user of result

## Setup

Setup can be broken into two sections. The Codeship / Bitbucket section will get you setup so that you can trigger a build via the codeship web UI. The Pantheon section will then allow the builds to get automatically triggered on commits.

### Codeship / Bitbucket setup
* Create a bitbucket repo and copy all the files from this repo into it
* Create a project on Codeship and hook it up to the bitbucket repo you just created.
* Configure your codeship test settings to look like the below :
  #### Setup commands
  ```bash
  ./run.sh PANTHEON_SITE PANTHEON_ENV PANTHEON_BRANCH
  ```
  Where *PANTHEON_SITE* is your pantheon project, *PANTHEON_ENV* is your pantheon environment and *PANTHEON_BRANCH* is your pantheon branch. eg `./run.sh my-site dev master`
  #### Test Pipeline
  ```bash
  mv ~/clone/behat.codeship.yml ~/clone/pantheon_repo/tests
  cd ~/clone/pantheon_repo/tests
  behat
  ```
* Configure codeship variables **PANTHEON_ROBOT** and **ROBOT_PASSWORD** that represent a Pantheon user with access to your project.

### Pantheon setup
* Copy *pantheon.yml* to the root of your pantheon directory
* Copy *codeship_integration.php* to *site_root/private/scripts/codeship_integration.php*
* Update codeship_integration_secrets.json with your codeship api key and the build id of your project. Once that's done copy to *files/private* in your pantheon sites file system


Once all of the above is done commits to Pantheon site should trigger a codeship build automagically !!
