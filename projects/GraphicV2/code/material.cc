#include "material.h"
#include "shaderResource.h"
#include "texture.h"


material::BlinnPhongMat::BlinnPhongMat(vec3 ambientV, vec3 diffuseV, vec3 specularV, float shininess)
	: ambient(ambientV), diffuse(diffuseV), specular(specularV), shininess(shininess)
{
}

void material::BlinnPhongMat::Apply(ShaderResource& program)
{
	for (auto& tex : textures)
		tex.Bind();
}
