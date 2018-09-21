let project = new Project('kha_test');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addSources('../lib/femto_ui/femto_ui-core');
project.addSources('../lib/femto_ui/backend/femto_ui-kha');
resolve(project);
