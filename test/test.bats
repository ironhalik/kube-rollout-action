# shellcheck disable=SC2030,SC2031
setup() {
    load 'lib/bats-support/load'
    load 'lib/bats-assert/load'

    export INPUT_DEBUG=true
    export INPUT_RESOURCE="deployment" # action default
    export INPUT_TIMEOUT="300s" # action default
    export INPUT_CONFIG="YXBpVmVyc2lvbjogdjEKY2x1c3RlcnM6Ci0gY2x1c3RlcjoKICAgIHNlcnZlcjogaHR0cDovL2V4YW1wbGUuY29tCiAgbmFtZTogdGVzdC1jbHVzdGVyCmNvbnRleHRzOgotIGNvbnRleHQ6CiAgICBjbHVzdGVyOiB0ZXN0LWNsdXN0ZXIKICAgIG5hbWVzcGFjZTogZGVmYXVsdAogICAgdXNlcjogdGVzdC11c2VyCiAgbmFtZTogdGVzdC1jb250ZXh0Ci0gY29udGV4dDoKICAgIGNsdXN0ZXI6ICIiCiAgICB1c2VyOiAiIgogIG5hbWU6IHRoZS1vdGhlci1jb250ZXh0CmN1cnJlbnQtY29udGV4dDogdGVzdC1jb250ZXh0CmtpbmQ6IENvbmZpZwpwcmVmZXJlbmNlczoge30KdXNlcnM6Ci0gbmFtZTogdGVzdC11c2VyCiAgdXNlcjoKICAgIHRva2VuOiB0ZXN0LXRva2VuCg=="

    DIR="$(cd "$( dirname "${BATS_TEST_FILENAME}" )" > /dev/null 2>&1 && pwd)"
    PATH="${DIR}/../:${PATH}"
}

teardown() {
    echo "" > /kubeconfig
}

@test "name and selector used together" {
    export INPUT_NAME="abc"
    export INPUT_SELECTOR="def"

    run kubectl-action.sh
    assert_output --partial "name and selector inputs cannot be used together"
    assert_failure
}

@test "name is used correctly" {
    export INPUT_NAME="some-deployment"

    run kubectl-action.sh
    assert_output --partial "kubectl rollout status deployment some-deployment --timeout 300s"
    assert_output --partial "the server could not find the requested resource"
    assert_failure
}

@test "name is used correctly (using env var)" {
    export NAME="some-deployment"

    run kubectl-action.sh
    assert_output --partial "kubectl rollout status deployment some-deployment --timeout 300s"
    assert_output --partial "the server could not find the requested resource"
    assert_failure
}

@test "selector is used correctly" {
    export INPUT_SELECTOR="hash=abc123"

    run kubectl-action.sh
    assert_output --partial "kubectl rollout status deployment --selector hash=abc123 --timeout 300s"
    assert_output --partial "the server could not find the requested resource"
    assert_failure
}

@test "timeout is used correctly" {
    export INPUT_TIMEOUT="1m"

    run kubectl-action.sh
    assert_output --partial "kubectl rollout status deployment --timeout 1m"
    assert_output --partial "the server could not find the requested resource"
    assert_failure
}
