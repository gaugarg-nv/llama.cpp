# cmake/FindNCCL.cmake

# NVIDIA does not distribute CMake files with NCCl, therefore use this file to find it instead.

find_path(NCCL_INCLUDE_DIR
    NAMES nccl.h
    HINTS ${NCCL_ROOT} $ENV{NCCL_ROOT} $ENV{CUDA_HOME} /usr/local/cuda $ENV{CUDA_PATH}
    PATH_SUFFIXES include
)

if(WIN32)
    find_library(NCCL_STATIC_LIBRARY
        NAMES nccl_static
        HINTS ${NCCL_ROOT} $ENV{NCCL_ROOT} $ENV{CUDA_PATH} $ENV{CUDA_HOME}
        PATH_SUFFIXES lib lib/x64
    )

    find_library(NCCL_DEVICE_LIBRARY
        NAMES nccl_device
        HINTS ${NCCL_ROOT} $ENV{NCCL_ROOT} $ENV{CUDA_PATH} $ENV{CUDA_HOME}
        PATH_SUFFIXES lib lib/x64
    )
else()
    find_library(NCCL_LIBRARY
        NAMES nccl
        HINTS ${NCCL_ROOT} $ENV{NCCL_ROOT} $ENV{CUDA_HOME} /usr/local/cuda
        PATH_SUFFIXES lib lib64
    )
endif()

include(FindPackageHandleStandardArgs)

if(WIN32)
    find_package_handle_standard_args(NCCL
        DEFAULT_MSG
        NCCL_STATIC_LIBRARY NCCL_DEVICE_LIBRARY NCCL_INCLUDE_DIR
    )
else()
    find_package_handle_standard_args(NCCL
        DEFAULT_MSG
        NCCL_LIBRARY NCCL_INCLUDE_DIR
    )
endif()

if(NCCL_FOUND)
    if(WIN32)
        set(NCCL_LIBRARIES ${NCCL_STATIC_LIBRARY} ${NCCL_DEVICE_LIBRARY})
    else()
        set(NCCL_LIBRARIES ${NCCL_LIBRARY})
    endif()
    set(NCCL_INCLUDE_DIRS ${NCCL_INCLUDE_DIR})

    if(NOT TARGET NCCL::NCCL)
        if(WIN32)
            add_library(NCCL::NCCL INTERFACE IMPORTED)
            set_target_properties(NCCL::NCCL PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${NCCL_INCLUDE_DIR}"
                INTERFACE_LINK_LIBRARIES "${NCCL_STATIC_LIBRARY};${NCCL_DEVICE_LIBRARY}"
            )
        else()
            add_library(NCCL::NCCL UNKNOWN IMPORTED)
            set_target_properties(NCCL::NCCL PROPERTIES
                IMPORTED_LOCATION "${NCCL_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${NCCL_INCLUDE_DIR}"
            )
        endif()
    endif()
endif()

if(WIN32)
    mark_as_advanced(NCCL_INCLUDE_DIR NCCL_STATIC_LIBRARY NCCL_DEVICE_LIBRARY)
else()
    mark_as_advanced(NCCL_INCLUDE_DIR NCCL_LIBRARY)
endif()
