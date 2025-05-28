classdef TestingConvention < matlab.buildtool.conventions.Convention
    properties
        ReportCoverage (1,1) logical = false;
        MexOutputFolder (1,1) string = "out";
        TestFolder (1,1) string = strcat("test",filesep);
        TestTagFiltering = {'Long Duration'};
    end

    methods
        function plan = apply(~, plan)
            % import matlab.buildtool.tasks.*
            % import matlab.buildtool.Task
            % 
            % tbxName = "Common Aerospace Functions";
            % plan("package") = Task(Description="Package the folder into an mltbx", ...
            % Dependencies=["mex" "pcode" "qualifyExt" "CodeIssues"], ...
            % Inputs=["out/**/*.*","external/**/*.*","examples/**/*.*"], Outputs="Common Aerospace Functions.mltbx", ...
            % Actions = @(ctx) packageTask(ctx, tbxName));
        end
    end
end

% function packageTask(~, packageName)
% % Package toolbox
% identifier = 'identifier';
% toolboxFolder = fullfile(pwd,"out");
% 
% opts = matlab.addons.toolbox.ToolboxOptions(toolboxFolder,identifier);
% 
% opts.ToolboxName = packageName;
% opts.ToolboxVersion = '1.0';
% opts.Description = "A blank description for now";
% opts.Summary = "This toolbox provides common functionalities needed and used in aerospace applications";
% 
% opts.AuthorName = "Youssef Noureddine";
% opts.AuthorEmail = "ynouredd@mathworks.com";
% opts.AuthorCompany = "The MathWorks";
% 
% opts.ToolboxImageFile = strcat("out",filesep,"Image.jpg");
% opts.ToolboxFiles = ["out";"external";"examples"];
% 
% opts.AppGalleryFiles = [strcat("examples",filesep,"workflow1.m"), ...
%     strcat("examples",filesep,"workflow2.m"), ...
%     strcat("examples",filesep,"workflow3.m"), ...
%     strcat("examples",filesep,"workflow4.m")];
% opts.ToolboxGettingStartedGuide = strcat("out",filesep,"GettingStarted.mlx");
% opts.OutputFile = fullfile(pwd,"Common Aerospace Functions");
% opts.MinimumMatlabRelease = "R2017b";
% opts.MaximumMatlabRelease = "";
% 
% opts.SupportedPlatforms.Win64 = true;
% opts.SupportedPlatforms.Maci64 = true;
% opts.SupportedPlatforms.Glnxa64 = true;
% opts.SupportedPlatforms.MatlabOnline = true;
% 
% matlab.addons.toolbox.packageToolbox(opts);
% end
