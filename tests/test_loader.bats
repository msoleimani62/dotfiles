#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    LOADER="$REPO_ROOT/configs/zsh/modules/loader.zsh"
}

@test "loader.zsh sources cleanly on first load" {
    run zsh -c "source '$LOADER' generic; echo ok"

    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]
}

@test "loader.zsh can be sourced a second time in the same shell (reload) without error" {
    run zsh -c "source '$LOADER' generic; source '$LOADER' generic; echo ok"

    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]
}

@test "reloading loader.zsh multiple times does not duplicate PATH entries" {
    run zsh -c "source '$LOADER' generic; source '$LOADER' generic; source '$LOADER' generic; print -l \$path | sort | uniq -d"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "DOTFILES_ZSH_ENV_LOADED reflects the requested environment after reload" {
    run zsh -c "source '$LOADER' generic; source '$LOADER' generic; echo \$DOTFILES_ZSH_ENV_LOADED"

    [ "$status" -eq 0 ]
    [ "$output" = "generic" ]
}
