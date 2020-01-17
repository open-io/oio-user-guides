#!/usr/bin/env bats

TEST_FILE=/tmp/test.txt
# BUCKET_NAME=quickstart-bucket
OIO_NAMESPACE=OPENIO

# This function is called for EACH test
setup() {
    cd "${BATS_TEST_DIRNAME}/../" || (echo "ERROR: cannot change directory to ${BATS_TEST_DIRNAME}. Exiting." && exit 1)
    # shellcheck disable=SC1091
    source ./.env
}

@test "We can start the docker-compose stack of this story" {
    docker-compose up -d --build --force-recreate
}

@test "OpenIO is started successfully" {
    local max_tries=20
    local wait_before_retry=5
    local counter=0
    until [ "${counter}" -ge "${max_tries}" ]
    do
        echo "==Trial number ${counter}"
        docker-compose exec openio-server bash -x -c "openio cluster list --ns=${OIO_NAMESPACE}" || break
        sleep "${wait_before_retry}"
        counter=$((counter + 1))
    done
    echo "== Final counter: ${counter}"
    [ ${counter} -lt ${max_tries} ]   
}

@test "We can store a file with OpenIO client" {
    docker-compose exec openio-client bash -c "echo 'Hello OIO' > ${TEST_FILE}"
    
    local max_tries=20
    local wait_before_retry=5
    local counter=0
    until [ "${counter}" -ge "${max_tries}" ]
    do
        echo "==Trial number ${counter}"
        docker-compose exec openio-client sbash -x -c "openio object create MY_OIO_CONTAINER ${TEST_FILE} --oio-account MY_ACCOUNT --ns=${OIO_NAMESPACE} --oio-proxy=${OIO_URL}:6006" || break
        sleep "${wait_before_retry}"
        counter+=1
    done
    echo "== Final counter: ${counter}"
    [ ${counter} -lt ${max_tries} ] 
}

# @test "We can store a file with AWS S3" {
#     docker-compose exec aws-client bash -c "echo 'Hello OIO' > ${TEST_FILE}"
#     docker-compose exec aws-client bash -x -c "aws --endpoint-url http://${S3_URL}:6007 s3 mb s3://${BUCKET_NAME}"
#     docker-compose exec aws-client bash -x -c "aws --endpoint-url http://${S3_URL}:6007 s3 cp ${TEST_FILE} s3://${BUCKET_NAME}/$(basename ${TEST_FILE})"
# }

@test "We can stop gracefully the docker-compose example" {
    docker-compose down -v --remove-orphans
}
