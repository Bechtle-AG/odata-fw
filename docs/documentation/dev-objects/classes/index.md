---
title: Classes
description: Overview of the classes of the framework
---
#  {{ $frontmatter.title }}

## Class Documentations

### Framework classes

1. [ZCL_ODATA_FW_CONTROLLER](./ZCL_ODATA_FW_CONTROLLER)
1. [ZCL_ODATA_FW_MPC](./ZCL_ODATA_FW_MPC)
1. [ZCL_ODATA_FW_CUST_DPC](./ZCL_ODATA_FW_CUST_DPC)
1. [ZCL_ODATA_DATA_PROVIDER](./ZCL_ODATA_DATA_PROVIDER)
1. [ZCL_ODATA_FW_CUST](./ZCL_ODATA_FW_CUST)

#### UML

```mermaid
classDiagram

	ZCL_ODATA_FW_MPC <-- ZCL_ODATA_FW_CONTROLLER
    ZCL_ODATA_FW_CUST_DPC <-- ZCL_ODATA_FW_CONTROLLER

	class ZCL_ODATA_FW_CONTROLLER{
        +define_dpc()
        +define_mpc()
	}

	class ZCL_ODATA_FW_MPC{
		+define_from_cust()
	}

    class ZCL_ODATA_FW_CUST_DPC{
		+read_entities()
		+read_global_namespaces()
		+read_properties()
		+read_propery_texts()
		+read_navigations()
		+read_seach_helps()
		+read_actions()
		+read_action_parameters()
	}

	class ZCL_ODATA_DATA_PROVIDER{
		+add()
		+add_entities2providers()
		+get_all()
		+get()
		+get_action()
	}

	class ZCL_ODATA_FW_CUST{
		+get_namespace()
		+get_entities()
		+get_properties()
		+get_property_texts()
		+get_navigation()
		+get_actions()
		+get_action_parameter()
		-load_customizing()
	}
```

### Helper classes

  1. [ZCL_ODATA_MAIN](./ZCL_ODATA_MAIN)
  1. [ZCL_ODATA_DOCUMENTS](./ZCL_ODATA_DOCUMENTS)
  1. [ZCL_ODATA_VALUE_HELP](./ZCL_ODATA_VALUE_HELP)

### UTIL classes

  1. [ZCL_ODATA_UTILS](./ZCL_ODATA_UTILS)
