classdef uninstallPackageTask < matlab.buildtool.Task
    properties
        OutputFolder matlab.buildtool.io.File {mustBeScalarOrEmpty}
    end

    methods
        function task = uninstallPackageTask(~)
        end

        function tf = runOnClient(~)
            tf = true;
        end
    end

    methods (TaskAction)
        function installMLTBX(~,~)
            clear mex
            s = matlab.addons.toolbox.installedToolboxes;
            if ~isempty(s)
                idx = find(strcmp({s.Name}, 'Common Aerospace Functions'));
                if ~isempty(idx)
                    s(idx)
                    matlab.addons.toolbox.uninstallToolbox(s(idx))
                end
            end
        end
    end
end