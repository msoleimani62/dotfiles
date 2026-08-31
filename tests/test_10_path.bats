#!/usr/bin/env bats

setup() {
    TEST_ROOT="$(mktemp -d)"
    MODULE="$BATS_TEST_DIRNAME/../configs/zsh/modules/10-path.zsh"
}

teardown() {
    rm -rf "$TEST_ROOT"
}

@test "zsh_path_latest_versioned_dir picks the highest build-tools version (3-component)" {
    mkdir -p "$TEST_ROOT/build-tools/30.0.3" "$TEST_ROOT/build-tools/34.0.0" "$TEST_ROOT/build-tools/33.0.1"

    result="$(zsh -c "source '$MODULE'; zsh_path_latest_versioned_dir '$TEST_ROOT/build-tools/*' ''")"

    [ "$(basename "$result")" = "34.0.0" ]
}

@test "zsh_path_latest_versioned_dir compares numerically, not lexicographically (9 vs 10)" {
    mkdir -p "$TEST_ROOT/build-tools/9.0.0" "$TEST_ROOT/build-tools/10.0.0"

    result="$(zsh -c "source '$MODULE'; zsh_path_latest_versioned_dir '$TEST_ROOT/build-tools/*' ''")"

    [ "$(basename "$result")" = "10.0.0" ]
}

@test "zsh_path_latest_versioned_dir picks the highest gradle version with a prefix" {
    mkdir -p "$TEST_ROOT/gradle-7.6" "$TEST_ROOT/gradle-8.5" "$TEST_ROOT/gradle-8.10"

    result="$(zsh -c "source '$MODULE'; zsh_path_latest_versioned_dir '$TEST_ROOT/gradle-*' 'gradle-'")"

    [ "$(basename "$result")" = "gradle-8.10" ]
}

@test "zsh_path_latest_versioned_dir returns empty when nothing matches" {
    result="$(zsh -c "source '$MODULE'; zsh_path_latest_versioned_dir '$TEST_ROOT/nope-*' ''")"

    [ -z "$result" ]
}

@test "zsh_path_normalize removes duplicate PATH entries" {
    result="$(zsh -c "source '$MODULE'; path=(/usr/bin /usr/local/bin /usr/bin /bin); zsh_path_normalize; print \$#path")"

    [ "$result" = "3" ]
}
