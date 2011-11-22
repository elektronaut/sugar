# A sample Guardfile
# More info at https://github.com/guard/guard#readme

#guard 'test' do
#  watch(%r{^lib/(.+)\.rb$})     { |m| "test/#{m[1]}_test.rb" }
#  watch(%r{^test/.+_test\.rb$})
#  watch('test/test_helper.rb')  { "test" }
#
#  # Rails example
#  watch(%r{^app/models/(.+)\.rb$})                   { |m| "test/unit/#{m[1]}_test.rb" }
#  watch(%r{^app/controllers/(.+)\.rb$})              { |m| "test/functional/#{m[1]}_test.rb" }
#  watch(%r{^app/views/.+\.rb$})                      { "test/integration" }
#  watch('app/controllers/application_controller.rb') { ["test/functional", "test/integration"] }
#end

guard 'rspec' do
  watch('spec/spec_helper.rb')                        { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
end