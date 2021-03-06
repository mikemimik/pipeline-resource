# Pipeline Resource For Concourse

This is a concourse resource that can interact with the current concourse instance.
It can create, update, and delete pipelines.

# Source Configuration
* `target`: _Required_. The `uri` to the concourse server. The same value you would pass to a `fly` command. (eg. `http://{ip-address | domain}:{port}`)
* `teams`: _Required_. Array of `team` objects. Contains `name`, `username`, and `password` for the concourse team.

# Behavior

## `CHECK`
> no-op function
## `IN`
> no-op function
## `OUT`

### Parameters
* `method`: _Required_. The action to take (`create`, `update`, or `remove`).
* `config_file`: _Required_. The path to a pipeline config yaml file.
* `params_file`: _Optional_. The path to the pipeline params yaml file. (Note: if no params file is needed, then this parameter must explicitly be set to `false`.)
* `should_start`: _Optional_. _Default `true`_
* `should_expose`: _Optional_. _Default `false`_

#### Selection
The `name` and `name_file` parameters are used to name and identify the pipeline. If you are creating a new pipeline this will become the name of the pipeline, or if you are updating/deleting a pipeline this parameter is used to identify the pipeline. You can not set both of these properties, it is either one or the other.

* `name`: _Optional_. String name of the pipeline (no spaces allowed).
* `name_file`: _Optional_. The path to a file containing the pipeline name (name in file can't contain any spaces).

# Caveats
- Resource will `fly expose` a pipeline by default, which might not be desired behaviour. (This will become an option under params in a future release)
- `fly login` command uses `--insecure` by default. If you're ATC has SSL configured, this will skip the verification of the certificate.
- If `fly login` fails (eg. network issues) the logs will leak credentials. It is recommended that a job using this resource should _**not**_ have the property `public: true`.

# Examples
#### Resource Type:
```
resource_types:
- name: pipeline-resource
  type: docker-image
  source:
    repository: mperrotte/pipeline-resource
```

#### Resource:
```
resources:
- name: pipeline-generator
  type: pipeline-resource
  source:
    target: http://localhost:8080
    teams:
    - name: main
      username: concourse
      password: changeme
```

```
resources:
- name: pipeline-generator
  type: pipeline-resource
  source:
    target: http://localhost:8080
    teams:
    - name: main
      username: concourse
      password: changeme
    - name: other_team
      username: other_concourse
      password: other_changeme
```

#### Plan usage
```
plan:
- get: some-git-resource
- task: generate-needed-files
  config:
    platform: linux
    image_resource:
      type: docker-image
      source:
        repository: alpine
        tag: latest
    inputs:
    - name: some-git-resource
    outputs:
    - name: workspace
    run:
      path: sh
      args:
      - -exc
      - |
        touch workspace/pipeline.yml
        touch workspace/params.yml
        touch workspace/name
- put: pipeline-generator
  params:
    method: create
    should_start: true
    team: main
    config_file: workspace/pipeline.yml
    params_file: workspace/params.yml
    name_file: workspace/name
```

```
plan:
- get: some-repo
- task: generate-needed-files
  config:
    platform: linux
    image_resource:
      ...
    inputs:
    - name: some-repo
    outputs:
    - name: workspace
    run:
      path: sh
      args:
      - -exc
      - |
        cp some-repo/team/some-pipeline.yml workspace/some-pipeline.yml
- put: pipeline-generator
  params:
    method: create
    should_start: true
    should_expose: true
    team: main
    config_file: workspace/some-pipeline.yml
    params_file: false
    name: some-team-pipeline
```