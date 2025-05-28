function plan = buildfile
import matlab.buildtool.tasks.*
import matlab.buildtool.Task

% Define a build plan
plan = buildplan(localfunctions);
plan("Clean") = CleanTask;
plan("CleanAfterInstall") = CleanTask;
plan("CodeIssues") = CodeIssuesTask;

% Use the MexOutputFolder property for the output folder
plan("mex") = MexTask.forEachFile(fullfile("src","**","*.c"), fullfile("out","MexFiles"));
plan("pcode") = PcodeTask(fullfile("src","**","*.m"), "out/PFiles");

tbxName = "Common Aerospace Functions";
plan("package") = Task(Description="Package the folder into an mltbx", ...
    Dependencies=["mex" "pcode" "qualifyExt" "CodeIssues"], ...
    Inputs=["out/**/*.*","external/**/*.*","examples/**/*.*"], Outputs=strcat(tbxName,".mltbx"), ...
    Actions = @(ctx) package(ctx, tbxName));

plan("installPackage") = installPackageTask(tbxName);
plan("installPackage").Dependencies = "package";
plan("installPackage").Description = "Install the packaged mltbx";

plan("CleanAfterInstall").Dependencies = "installPackage";


% We want to test the packaged toolbox, so clean necessary to remove
% functions still present locally
TestResultFile = "report.mat";
plan("test") = TestTask(strcat("tests",filesep),TestResults = TestResultFile);
plan("test").Dependencies = ["installPackage","CleanAfterInstall"];

plan("TagFilteredTest") = TestTask(SourceFiles="out",Tag="GradientMethod",TestResults="TagTestResult.mat");
plan("TagFilteredTest").Dependencies = ["mex", "pcode", "CodeIssue"];

plan("uninstallPackage") = uninstallPackageTask;
plan("uninstallPackage").Description = "Uninstall the packaged mltbx";

Conv1 = TestingConvention;
Conv1.MexOutputFolder = fullfile("out","MexFiles");
Conv1.TestTagFiltering = "GradientMethod";
Conv1.TestFolder = strcat("tests",filesep);
plan = plan.applyConvention(Conv1);

plan.DefaultTasks = ["mex", "pcode", "coverage"];
end

% Independent Branch Tasks
function qualifyExtTask(~)
cd external
buildtool mex -verbosity 0
buildtool test -verbosity 0
cd ..
end

function package(~, packageName)
% Package toolbox
identifier = char(randi([97 122], 1, 5));
toolboxFolder = fullfile(pwd,"out");

opts = matlab.addons.toolbox.ToolboxOptions(toolboxFolder,identifier);

opts.ToolboxName = packageName;
opts.ToolboxVersion = ['1.' num2str(randi([0 99]))];
opts.Description = "A blank description for now";
opts.Summary = "This toolbox provides common functionalities needed and used in aerospace applications";

opts.AuthorName = "Youssef Noureddine";
opts.AuthorEmail = "ynouredd@mathworks.com";
opts.AuthorCompany = "The MathWorks";

opts.ToolboxImageFile = strcat("out",filesep,"Image.jpg");
opts.ToolboxFiles = ["out";"external";"examples"];

opts.AppGalleryFiles = [strcat("examples",filesep,"workflow1.m"), ...
    strcat("examples",filesep,"workflow2.m"), ...
    strcat("examples",filesep,"workflow3.m"), ...
    strcat("examples",filesep,"workflow4.m")];
opts.ToolboxGettingStartedGuide = strcat("out",filesep,"GettingStarted.mlx");
opts.OutputFile = fullfile(pwd,"Common Aerospace Functions");
opts.MinimumMatlabRelease = "R2017b";
opts.MaximumMatlabRelease = "";

opts.SupportedPlatforms.Win64 = true;
opts.SupportedPlatforms.Maci64 = true;
opts.SupportedPlatforms.Glnxa64 = true;
opts.SupportedPlatforms.MatlabOnline = true;

matlab.addons.toolbox.packageToolbox(opts);
end
