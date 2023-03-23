# Spawns a task to run in the background
#
# Please note that it spawns a fresh nushell process to execute the given command.
# This means that it does not inherit current scope variables, custom commands, and alias definition. Environment variables are passed, however.
#
# e.g:
# spawn { echo 3 }
export def spawn [
    --group (-g): string = "default", # The group
    command: block                    # The command to spawn
] {
    let source_code = (view source $command | str trim -l -c '{' | str trim -r -c '}')
    let config_path = $nu.config-path
    let env_path = $nu.env-path

    let nu_wrapper = $"nu --config \"($config_path)\" --env-config \"($env_path)\" -c '($source_code)'"

    let job_id = (pueue add --group $group --print-task-id $nu_wrapper)
    {"job_id": $job_id}
}

# Spawns a task to run in the background. Unlike `spawn`, it uses `sh` rather than `nu`
export def "spawn raw" [
    --group (-g): string = "default", # The group
    command: string
] {
    let job_id = (pueue add --group $group --print-task-id $command)    
    {"job_id": $job_id}
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
    if $signal == null {
        pueue kill $id
    } else {
        pueue kill --signal $signal $id
    }
}

# Cleans a group's job log
export def clean [
    --group (-g): string = "default" # The group
] {
    pueue clean --group $group
}
