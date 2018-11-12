let project = new Project('kha_test');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');

project.addSources('../lib/femto_ui/femto_ui-core');
project.addSources('../lib/femto_ui/backend/femto_ui-kha');

project.addSources('../lib/konsole/konsole-core');
project.addSources('../lib/konsole/backend/konsole-kha');

project.addSources('../lib/femto_ui/test');

project.addLibrary('buddy');
project.addLibrary('hscript');

project.windowOptions.width = 1200;
project.windowOptions.height = 800;
resolve(project);
