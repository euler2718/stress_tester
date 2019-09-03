# Concurrent

**TODO:**

1)Generalize createTasks method to handle any/all from the Concurrent struct

2)GenStages for full application tests (one lambda at a time, but multiple concurrent application tests)

## Installation

clone

mix deps.get

## Usage

1) alter the lib/concurrent.ex file to point to correct url and x-api-key
2) alter the lib/request_body.json to include proper request
3*) iex> Concurrent.createTasks(100)
                => this will run 100 requests
                
                OR
3*) iex> Concurrent.createTasks(%Concurrent{filename: "sample_request_filePath"}, 100)

