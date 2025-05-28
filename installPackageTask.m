classdef installPackageTask < matlab.buildtool.Task
    properties
        OutputFolder matlab.buildtool.io.File {mustBeScalarOrEmpty}
    end

    methods
        function task = installPackageTask(outputMLTBXName)
            arguments
                outputMLTBXName 
            end

            task.OutputFolder = outputMLTBXName;
        end

        function tf = runOnClient(~)
            tf = true;
        end
    end

    methods (TaskAction)
        function installMLTBX(task,~)
            ls
            task.OutputFolder.Path
            matlab.addons.toolbox.installToolbox(strcat(task.OutputFolder.Path, ".mltbx"))
        end
    end
end