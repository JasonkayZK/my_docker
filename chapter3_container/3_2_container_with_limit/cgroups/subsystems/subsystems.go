package subsystems

var (
	SubsystemIns = []Subsystem{
		&CpuSetSubSystem{},
		&MemorySubSystem{},
		&CpuSubSystem{},
	}

	CgroupConfigPath = "tasks"
)

// ResourceConfig 用于传递资源限制的结构体
type ResourceConfig struct {
	MemoryLimit string // 内存限制
	CpuShare    string // CPU时间片权重
	CpuSet      string // CPU核心数
}

// Subsystem Subsystem接口
// 这里将 cgroups 抽象为了 path，因为 cgroups 在 hierarchy 的路径就是虚拟文件系统中的路径！
type Subsystem interface {
	// Name 返回subsystem的名称，如：cpu、memory等
	Name() string

	// Set 设置某个cgroup在这个subsystem中的资源限制
	Set(path string, res *ResourceConfig) error

	// Apply 将指定pid对应的进程添加至某个cgroup中
	Apply(path string, pid int) error

	// Remove 移除某个cgroup
	Remove(path string) error
}
