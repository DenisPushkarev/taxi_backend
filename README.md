# TaxiBackend

This is a demo project. RESTful backend service on Elixir for simple taxi service.
Demonstrates the processing of Geo data, finding nearest geo points.

## Get Started

To use this project docker and docker-compose need to be installed on your machine.

Start database instance:
```
docker-compose up
```

*Use `-d` to run in the background.*
*Use `--build` to ensure images are rebuilt.*
*Use `docker-compose down` to stop all services.*

Setup env variables for dabase access:
```
POSTGRES_USER=user
POSTGRES_PASSWORD=password
```


Init database and load demo data with the command:
```
mix ecto.init
```
Available logins for testing:
- user: driver, password: driver, role: driver
- user: driver1, password: driver1, role: driver
- user: driver2, password: driver2, role: driver
- user: manager, password: manager, role: manager
- user: manager1, password: manager1, role: manager
- user: manager2, password: manager2, role: manager

HTTP endpoint available at: [http://localhost:4001/](http://localhost:4001/)

# REST API

## Login
### Request

`POST /login`

    curl --location --request POST 'localhost:4001/login' \
      --header 'Content-Type: application/json' \
      --data-raw '{
        "login": "manager",
        "password": "manager"
    }'

### Response

    HTTP/1.1 200 OK
    Date: Thu, 24 Feb 2011 12:36:30 GMT
    Status: 200 OK

    {
    "role": "manager",
    "token": "jwt_token",
    "uuid": "ae927182-06e9-4c04-9723-3aeb64c8f74a"
    }

## Manager. Get list of tasks
### Request

`GET /manager/task/list`

    curl --location --request GET 'localhost:4001/manager/task/list' \
      --header 'Authorization: Bearer {JWT_TOKEN}' \
      --data-raw ''

### Response

    HTTP/1.1 202 OK
    Date: Thu, 24 Feb 2011 12:36:30 GMT
    Status: 200 OK

    {
    "tasks": [
        {
            "driver": null,
            "end_lat": 40.75159,
            "end_lng": -73.9892,
            "note": "10 Madison Sq W, New York, New York 10010 -> West 34th Street, New York, NY, USA",
            "start_lat": 40.74266,
            "start_lng": -73.9892,
            "status": "new",
            "task_id": "cee9a238-9ff2-404d-a49f-166ec85ac8eb"
        },
        ...
    ]
    }

## Manager. Get task by id
### Request

`GET /manager/task/{TASK_ID}/get`

    curl --location --request GET 'localhost:4001/manager/task/cee9a238-9ff2-404d-a49f-166ec85ac8eb/get' \
    --header 'Authorization: Bearer {JWT_TOKEN}' \
    --data-raw ''

### Response

    HTTP/1.1 202 OK
    Date: Thu, 24 Feb 2011 12:36:30 GMT
    Status: 200 OK

    {
    "driver": null,
    "end_lat": 40.75159,
    "end_lng": -73.9892,
    "note": "10 Madison Sq W, New York, New York 10010 -> West 34th Street, New York, NY, USA",
    "start_lat": 40.74266,
    "start_lng": -73.9892,
    "status": "new",
    "task_id": "cee9a238-9ff2-404d-a49f-166ec85ac8eb"
    }



## Driver. Get list of tasks, nearest first
### Request

`GET /driver/task/find?lat={latitude}&lng={longitude}`

    curl --location --request GET 'localhost:4001/driver/task/find?lat=52.72075&lng=37.617298' \
    --header 'Authorization: Bearer {JWT_TOKEN}' \
    --data-raw ''

### Response

    HTTP/1.1 200 OK
    Date: Thu, 24 Feb 2011 12:36:30 GMT
    Status: 200 OK

    {
    "tasks": [
        {
            "distance": "3499",
            "end_lat": 53.7236,
            "end_lng": 91.4617,
            "note": null,
            "start_lat": 53.7236,
            "start_lng": 91.4617,
            "status": "new",
            "task_id": "18a4b282-17ad-41cc-a931-a9b171ad35c5"
        },
        ...
    ]
    }

## Driver. Start task
### Request

`GET /driver/task/{task_id}/start`

curl --location --request PUT 'localhost:4001/driver/task/ad7b6ed6-3e5d-4e5e-94f5-af6d2787a231/start' \
--header 'Authorization: Bearer {JWT_TOKEN}' \
--data-raw ''
### Response

    HTTP/1.1 200 OK
    Date: Thu, 24 Feb 2011 12:36:30 GMT
    Status: 200 OK

    {
    "task_id": "18a4b282-17ad-41cc-a931-a9b171ad35c5"
    }
## Driver. Finish task
### Request

`GET /driver/task/{task_id}/finish`

    curl --location --request PUT 'localhost:4001/driver/task/ad7b6ed6-3e5d-4e5e-94f5-af6d2787a231/start' \
    --header 'Authorization: Bearer {JWT_TOKEN}' \
    --data-raw ''
### Response

    HTTP/1.1 200 OK
    Date: Thu, 24 Feb 2011 12:36:30 GMT
    Status: 200 OK

    {
    "task_id": "18a4b282-17ad-41cc-a931-a9b171ad35c5"
    }