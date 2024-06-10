package test

import (	
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func configureTerraformOptions(t *testing.T, terraformDir string, tfModule string) (*terraform.Options) {
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Targets: []string{tfModule},
	}
	return terraformOptions
}

func TestExamplesBasic(t *testing.T) {

	terraformApplyOptions := configureTerraformOptions(t, "../examples/boomi-molecule-with-new-vpc", "module.boomi-eks-molecule")
	terraformOptionsDestroyDeployOptions := configureTerraformOptions(t, "../examples/boomi-molecule-with-new-vpc", "module.boomi-eks-molecule.null_resource.boomi_undeploy")
	terraformOptionsDestroyOptions := configureTerraformOptions(t, "../examples/boomi-molecule-with-new-vpc", "module.boomi-eks-molecule")
		
	defer terraform.Destroy(t, terraformOptionsDestroyOptions)
	defer terraform.Destroy(t, terraformOptionsDestroyDeployOptions)
	terraform.InitAndApply(t, terraformApplyOptions)
}
