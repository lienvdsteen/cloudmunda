## [Unreleased]

- Remove runs_in_development mode

## [0.2.0] - 2022-08-26

**Breaking changes**

- Removed Usertask API (moved to (better maintained gem)[https://github.com/lienvdsteen/camunda]).

## [0.1.6] - 2022-08-11

- Fix for 0.1.4 changes. This resulted in *only* running the `-dev` type and not the production type.

## [0.1.5] - 2022-08-09
- Remove usage of Concurrent::TimerTask's timeout_interval since it has been deprecated.

## [0.1.4] - 2022-08-09
- Rework how we use `runs_in_development` together with `type`. This is a very biased approach. What we do from now on if when in your job definition `runs_in_development` equals to true, we will add `-dev` to the type name. 

## [0.1.3] - 2022-02-25
- Fix bug in `Supervisor#start` that would lead to not gracefully shutting down workers.

## [0.1.2] - 2022-02-25
- Add class method `runs_in_development` to Cloudmunda::Worker. This way you can run only specific jobs in development.

## [0.1.1] - 2021-12-16

- Camunda Cloud Access Token Creation
- Zeebe task workers
- Camunda Cloud Usertasks graphQL connection

## [0.1.0] - 2021-12-16

- Initial release