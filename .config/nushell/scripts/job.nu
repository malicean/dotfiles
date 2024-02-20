# Spawns a task to run in the background
#
# Please note that it spawns a fresh nushell process to execute the given command.
# This means that it does not inherit current scope variables, custom commands, and alias definition. Environment variables are passed, however.
#
# e.g:
# spawn { echo 3 }
export def spawn [
    --group (-g): string = "default", # The group
    command: closure                  # The command to spawn
] {
    let source_code = (view source $command | str trim -l -c '{' | str trim -r -c '}')
    let config_path = $nu.config-path
    let env_path = $nu.env-path

    let nu_wrapper = $"nu --config \"($config_path)\" --env-config \"($env_path)\" -c '($source_code)'"

    spawn raw --group $group $nu_wrapper
}

# Spawns a task to run in the background. Unlike `spawn`, it uses `sh` rather than `nu`
export def "spawn raw" [
    --group (-g): string = "default", # The group
    command: string
] {
    let id = pueue add --group $group --print-task-id $command | into int
    {"id": $id}
}

# Displays the current groups
export def group [] {
    pueue group --json
    | from json
    | transpose name
    | flatten --all
}

# Adds a new group. Returns `false` if the group already exists, in which case the parallel task limit may not match the value of `--parallel (-p)`
export def "group add" [
    --parallel (-p): int, # The number of tasks the group can run in parallel 
    name: string          # The group name
] {
    let result = (if $parallel == null {
        pueue group add $name
    } else {
        pueue group add --parallel $parallel $name
    } | str trim)

    if $result == $"Group \"($name)\" is being created" {
        return true
    }

    if $result == $"Group \"($name)\" already exists" {
        return false
    }

    error make { msg: $"unknown output: ($result)" }
}

# Removes a group. Returns `false` if the group did not exist
export def "group remove" [
    name: string # The group name
] {
    let result = pueue group remove $name | str trim

    if $result == $"Group \"($name)\" is being removed" {
        return true
    }

    if ($result | str starts-with $"Group ($name) doesn't exists") {
        return false
    }

    error make { msg: $"unknown output: ($result)" }
}

# Updates the parallel task limit of a group. Returns `false` if the group did not exist
export def "group parallel" [
    --auto (-a) # Automatically creates the group with the given parallel task limit if it does not exist
    name: string      # The group name
    count: int        # The maximum amount of parallel tasks
] {
    let result = pueue parallel --group $name $count | str trim

    if $result == $"Parallel tasks setting for group \"($name)\" adjusted" {
        return true
    }

    if ($result | str starts-with $"Group ($name) doesn't exists") {
        if not $auto { 
            return false
        }

        if (group add --parallel $count $name) {
            return true
        }

        error make { msg: "group initially did not exist, but did once attempting to create it" }
    }

    error make { msg: $"unknown output: ($result)" }
}

# Displays a job's log
export def log [
    id: int  # The job ID
] {
    pueue log --full --json $id
    | from json
    | transpose -i info
    | flatten --all
    | flatten --all
    | flatten status
}

# Get a group's jobs
export def status [
    --group (-g): string = "default" # The group
] {
    pueue status --group $group --json
    | from json
    | get tasks
    | transpose -i status
    | flatten
    | flatten status
}

# Kills a specific job
export def kill [
    --signal (-s): int, # The signal to send to the process
    id: int # The job ID
] {
    let result = (if $signal == null {
        pueue kill $id
    } else {
        pueue kill --signal $signal $id
    } | str trim)

    if $result == $"Tasks are being killed: ($id)" {
        return true
    }

    if $result == $"The command failed for tasks: ($id)" {
        error make {
            msg: "failed to kill job",
            label: {
                text: $"job ID: ($id)",
                span: (metadata $id).span
            }
        }
    }

    error make { msg: $"unknown output: ($result)" }
}

# Cleans a group's job log
export def clean [
    --group (-g): string = "default" # The group
] {
    pueue clean --group $group | ignore
}
