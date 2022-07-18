# Concourse GithubApps Content Resource

A [Concourse](https://concourse-ci.org/) resource for Clone Github private repository without personal credential.

## Preparation
You need Github App and install to your organization or repository.
App must have 'content' read access priviledge.

## Config
- `appID`: *Reqrueid.* GithubApp App ID
- `private_key`: *Required.* GithubApp private key
- `account`: *Required.* Github username or organization name which has target repository
- `repository`: *Required.* repository name which you want to pull
- `branch`: *Optional.* target branch name (default: main)

## Example

This is handy example so I wrote out private key section but ofcourse this is ***Extremely insecure***. You should replace it to var like ((githubapp-private-key)) and use [credential manager](https://concourse-ci.org/creds.html).

```yaml
resource_types:
  - name: githubapps-content
    type: docker-image
    source:
      repository: ghcr.io/totegamma/githubapps-content-resource
      tag: master

resources:
  - name: ci
    type: githubapps-content
    icon: github
    source:
      appID: YOUR_APP_ID
      private_key: |
        -----BEGIN RSA PRIVATE KEY-----
        .........
        -----END RSA PRIVATE KEY-----
      account: YOUR_ORG_NAME
      repository: YOUR_REPO_NAME
      branch: master

jobs:
  - name: pullcheck
    public: true
    plan:
      - get: ci
        trigger: true
      - task: pullcheck
        config:
          platform: linux
          image_resource:
            type: registry-image
            source: {repository: busybox}
          inputs:
            - name: ci
          run:
            path: sh
            args:
              - -cx
              - |
                ls ci
```

## Behaviour

### `check`: Check for latest commit is updated.
If the HEAD of the branch is updated, return the latest commit sha.
Otherwise return empty.

note: This means only latest commit change will detected. If there are many commit between concourse's resource check, only latest one will proceed.

### `in`: Clone the repository, at the given ref.
Clones the repository to the destination, and locks it down to a given ref. It will return the same given ref as version.

### `out`: Not supported.

