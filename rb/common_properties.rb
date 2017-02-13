#######################################################
# Load Default common properties
#######################################################
if File.file?("config/default/common_properties.yaml") then
	# Default common properties loaded from yaml file
	require 'yaml'
	@default_common_properties = YAML.load_file(File.open("config/default/common_properties.yaml"))
else
	# Empty default common properties
	@default_common_properties = {}
end

#######################################################
# Load User common properties
#######################################################
if File.file?("config/user/common_properties.yaml") then
	# User common properties loaded from yaml file
	require 'yaml'
	@user_common_properties = YAML.load_file(File.open("config/user/common_properties.yaml"))
else
	# Empty user common properties
	@user_common_properties = {}
end

#######################################################
# Function to get common properties
#######################################################
def get_common_property(propertyKey)
	if nil != @user_common_properties[propertyKey] then
		return @user_common_properties[propertyKey]
	elsif nil != @default_common_properties[propertyKey] then
		return @default_common_properties[propertyKey]
	else
		Kernel.abort("No user or default property found with key: " + propertyKey)
	end
end