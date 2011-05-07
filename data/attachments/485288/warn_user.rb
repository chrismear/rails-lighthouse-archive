From c7a555866481f83fc8c900c166d10ef194d39dae Mon Sep 17 00:00:00 2001
From: Ravinder Singh <ravinderrana30@gmail.com>
Date: Fri, 16 Apr 2010 16:58:14 +0530
Subject: [PATCH] Bug#3435 - warn user if options are given before application name

---
 .../rails/generators/rails/app/app_generator.rb    |    1 +
 railties/test/generators/app_generator_test.rb     |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/railties/lib/rails/generators/rails/app/app_generator.rb b/railties/lib/rails/generators/rails/app/app_generator.rb
index 6818faf..363e9f6 100644
--- a/railties/lib/rails/generators/rails/app/app_generator.rb
+++ b/railties/lib/rails/generators/rails/app/app_generator.rb
@@ -54,6 +54,7 @@ module Rails::Generators
                         :desc => "Show this help message and quit"
 
     def initialize(*args)
+      raise Error, "Options should be given after the application name. For details run: rails --help" if args[0].blank?
       super
       if !options[:skip_activerecord] && !DATABASES.include?(options[:database])
         raise Error, "Invalid value for --database option. Supported for preconfiguration are: #{DATABASES.join(", ")}."
diff --git a/railties/test/generators/app_generator_test.rb b/railties/test/generators/app_generator_test.rb
index 24e6d54..e57b5e1 100644
--- a/railties/test/generators/app_generator_test.rb
+++ b/railties/test/generators/app_generator_test.rb
@@ -58,6 +58,11 @@ class AppGeneratorTest < Rails::Generators::TestCase
     assert_no_file "public/stylesheets/application.css"
   end
 
+  def test_options_before_application_name_raises_an_error
+    content = capture(:stderr){ run_generator(["--skip-activerecord", destination_root]) }
+    assert_equal "Options should be given after the application name. For details run: rails --help\n", content
+  end
+  
   def test_name_collision_raises_an_error
     content = capture(:stderr){ run_generator [File.join(destination_root, "generate")] }
     assert_equal "Invalid application name generate. Please give a name which does not match one of the reserved rails words.\n", content
-- 
1.6.3.3

