package utils

import (
	"my_docker/cgroups/subsystems"
	"testing"
)

func TestFindCgroupMountPoint(t *testing.T) {
	t.Logf("cpu subsystem mount point %v\n", FindCgroupMountPoint(subsystems.CpuName))
	t.Logf("cpuset subsystem mount point %v\n", FindCgroupMountPoint(subsystems.CpuSetName))
	t.Logf("memory subsystem mount point %v\n", FindCgroupMountPoint(subsystems.MemoryName))
}
