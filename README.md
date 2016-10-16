# continuous-testing

Setup Commands
./run.sh pantheon-env dev master


Configure Test Pipelines
mv ~/clone/behat.codeship.yml ~/clone/pantheon_repo/tests
cd ~/clone/pantheon_repo/tests
behat
