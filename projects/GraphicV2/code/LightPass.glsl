#shader vertex
#version 430 core

layout(location = 0) in vec3 position;

uniform mat4 projView;
uniform mat4 model;


void main()
{
	gl_Position = projView * model * vec4(position,1);
}

#shader fragment
#version 430 core

struct PointLight {
    vec3 position;
    vec3 color;
	float intensity;
	float radius;

    float constant;
    float linear;
    float quadratic;
};

layout(location = 0) out vec4 color;

layout(binding = 0) uniform sampler2D gPosition;
layout(binding = 1) uniform sampler2D gNormal;
layout(binding = 2) uniform sampler2D gAlbedoSpec;



uniform vec3 camPos; //Get the camera position from main
uniform vec2 resolution; //Window resolution


uniform PointLight pointLight;  

vec3 CalcPointLight(PointLight light, vec3 norm, vec3 crntPos, vec3 viewDir,vec4 albedoSpecular);


void main()
{
	vec2 texCoord = gl_FragCoord.xy / resolution;

	vec3 crntPos = texture(gPosition, texCoord).xyz;
	vec3 norm = normalize(texture(gNormal,texCoord).xyz);
	vec4 albedoSpec = texture(gAlbedoSpec,texCoord);

    vec3 viewDirection = normalize(camPos - crntPos);
	
	color = vec4(CalcPointLight(pointLight,norm,crntPos,viewDirection,albedoSpec),1);
	
}

vec3 CalcPointLight(PointLight light, vec3 norm, vec3 crntPos, vec3 viewDir, vec4 albedoSpecular)
{
	//Blin Phong
	float shininess = 32.0f;

	//Calculate the direction and the falloff of the light
	vec3 lightDir = normalize(light.position - crntPos); 
	float distance = length(light.position - crntPos);

	float fade = 1.0 - smoothstep(light.radius * 0.8, light.radius, distance);

	if(fade <= 0.0)
		return vec3(0,0,0);

	//Diffuse
	float diffuseCoefficient = max(dot(lightDir,norm), 0.0f);
	
	//Specular light
	vec3 halfwayDir = normalize(lightDir + viewDir); 
	float specularAmount = pow(max(dot(norm, halfwayDir), 0.0f),shininess);


	//Combine the result
	vec3 diffuse = ((diffuseCoefficient) * light.color);
	vec3 specular = ((specularAmount * albedoSpecular.a) * light.color);
	
	
	// Smooth attenuation
    float distanceFactor = distance / light.radius;
    float attenuation = clamp(1.0 - distanceFactor * distanceFactor, 0.0, 1.0);
    attenuation *= attenuation; // Quadratic falloff for light
	//float attenuation = 1.0f / (light.constant +  light.linear * distance + light.quadratic * distance * distance);

	return (diffuse + specular)  * attenuation * fade * albedoSpecular.rgb * light.intensity;
}