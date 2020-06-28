# TaxiBackend

This is a demo project. Backend on Elixir for simple taxi service.

## Installation

TODO: ...

### API
#### Login
  POST /login
  JSON: {
    login: login
    password: password
  }

  Success response
  200
  JSON: {
    uuid: USER_ID
    role: 'manager' || 'driver'
    token: TOKEN
  }
  Auth failed
  401 Unauthorized
  {
    error: 'Authorisation failed'
  }

#### Driver
  GET /driver/tasks
  params: latitude=&longitude=[&limit=N&from=]
  SUCCESS: 200
  { total: N,
    tasks: [
      {
        id: TASK_ID,
        from: {
          latitude,
          longitude,
        },
        to: {
          latitude,
          longitude,
        },
      },
      ....
    ],
  }
  PUT /driver/tasks/TASK_ID/start
  SUCCESS:
  CODE: 202
  {
    status: OK
  }
  FAIL:
  CODE: 406
  {
    error: 'error description' // task has already been taken
    error_code: XX
  }

  PUT /driver/tasks/TASK_ID/done
  SUCCESS:
  CODE: 202
  {
    status: OK
  }
  FAIL:
  CODE: 406
  {
    error: 'error description' // task has already been taken
    error_code: XX
  }
  CODE: 404

  #### Manager
  GET /manager/tasks
  { total: N,
    tasks: [
      {
        id: TASK_ID,
        from: {
          latitude,
          longitude,
        },
        to: {
          latitude,
          longitude,
        },
        status: 'done' || 'started'
        started_at: 'datetime'
        finished_at: 'datetime'
      },
      ....
    ],
  }

  POST /manager/task/new
  {
    from: {
          latitude,
          longitude,
        },
    to: {
      latitude,
      longitude,
    },
  }
  SUCCESS:
  CODE: 202
  {
    task_id: NNNN
  }


