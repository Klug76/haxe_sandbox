let project = new Project('kha_test');
//var project = new Project('kha_test');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');

project.addLibrary('hscript');
project.addLibrary('gs');
project.addLibrary('json5mod');
project.addLibrary('femto_ui-core');
project.addLibrary('femto_ui-kha');
project.addLibrary('konsole-core');
project.addLibrary('konsole-kha');

project.windowOptions.width = 1200;
project.windowOptions.height = 800;
resolve(project);
//return project;
