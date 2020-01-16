#!/usr/bin/env bats

@test "We can start the docker-compose stack of this story" {
    cd "${BATS_TEST_DIRNAME}/../"
    docker-compose up -d --build --force-recreate
}

@test "We can store a file with OpenIO client" {
    cd "${BATS_TEST_DIRNAME}/../"
    local TEST_FILE=test.txt
    source ./.env
    sleep 5 # Assuming 5 s are enough to have SDS availables. TODO: Add a finite state droid for retries with timeout
    docker-compose exec openio-client bash -c "echo 'Hello OIO' > ${TEST_FILE}"
    docker-compose exec openio-client openio object create MY_OIO_CONTAINER ${TEST_FILE} --oio-account MY_ACCOUNT --ns=OPENIO --oio-proxy="${OIO_URL}:6006"
}


@test "We can stop gracefully the docker-compose example" {
    cd "${BATS_TEST_DIRNAME}/../"
    docker-compose down -v --remove-orphans
}
