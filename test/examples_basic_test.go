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
	terraformDestroyOptions := configureTerraformOptions(t, "../examples/boomi-molecule-with-new-vpc", "module.boomi-eks-molecule")
	
	terraform.InitAndApply(t, terraformApplyOptions)
	defer terraform.Destroy(t, terraformDestroyOptions)
}
