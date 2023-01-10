load('ext://uibutton', 'cmd_button', 'text_input', 'location')
load('ext://namespace', 'namespace_create')

repo = local_git_repo('.')

config.define_string_list("helm_overrides", args=True)
cfg = config.parse()

docker_build('mtls-app', '.',
  dockerfile='Dockerfile',
  live_update=[
    # Map the local source code into the container under /src
    sync('.', '/app'),

    sync('./package.json', '/app/package.json'),

    run('yarn install', trigger=[
      'package.json'
    ]),
  ]
)

namespace = 'mtls'

k8s_yaml(helm(
  'k8s',
  name='mtls',
  namespace=namespace,
  values=['k8s/values.yaml'],
  set=cfg.get('helm_overrides', [])
))