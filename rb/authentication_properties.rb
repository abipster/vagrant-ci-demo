#######################################################
# Load User authentication properties
#######################################################
if File.file?("config/user/authentication_properties.yaml") then
	# User authentication properties loaded from yaml file
	require 'yaml'
	@user_authentication_properties = YAML.load_file(File.open("config/user/authentication_properties.yaml"))
else
	# Empty user authentication properties
	@user_authentication_properties = {}
end

#######################################################
# Function to get authentication properties
#######################################################
def get_authentication_property(propertyKey, promptMessage)
	if nil != @user_authentication_properties[propertyKey] then
		return @user_authentication_properties[propertyKey]
	else
		puts promptMessage
		propertyValue = STDIN.gets.chomp
		return propertyValue
	end
end

#######################################################
# Function to get authentication password
#######################################################
def get_authentication_password(propertyKey, promptMessage)
	if nil != @user_authentication_properties[propertyKey] then
		return @user_authentication_properties[propertyKey]
	else
		puts promptMessage
		passwordValue = STDIN.noecho(&:gets).chomp
		return passwordValue
	end
end