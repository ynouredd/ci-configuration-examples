function plan = buildfile
import matlab.buildtool.tasks.*
plan = buildplan;
plan("mex") = MexTask("src/gradientmethod.c", "src");
plan("test") = TestTask("external/test",SourceFiles="src");
plan("test").Dependencies = "mex";
plan("clean") = CleanTask;
plan.DefaultTasks = ["mex", "test", "clean"];
end
