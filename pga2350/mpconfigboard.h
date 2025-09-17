// Board and hardware specific configuration

// Board and hardware specific configuration
#ifndef MICROPY_HW_BOARD_NAME
// Might be defined by mpconfigvariant_VARIANT.cmake
#define MICROPY_HW_BOARD_NAME                   "PGA2350"
#endif

// Portion of onboard flash to reserve for the user filesystem
// PGA2350 has 16MB flash, so reserve 2MiB for the firmware and leave 14MiB
#define MICROPY_HW_FLASH_STORAGE_BYTES          (14 * 1024 * 1024)

// Alias the chip select pin specified by pga2350.h
#define MICROPY_HW_PSRAM_CS_PIN                 PIMORONI_PGA2350_PSRAM_CS_PIN

// Enable networking for wireless support
#define MICROPY_PY_NETWORK 1
#define MICROPY_PY_NETWORK_CYW43 1
#define MICROPY_PY_LWIP 1
#define MICROPY_PY_NETWORK_HOSTNAME_DEFAULT     "PGA2350"

// CYW43 driver configuration for wireless
#define CYW43_USE_SPI (1)
#define CYW43_LWIP (1)
#define CYW43_GPIO (1)
#define CYW43_SPI_PIO (1)

#define MICROPY_HW_PIN_EXT_COUNT    CYW43_WL_GPIO_COUNT

int mp_hal_is_pin_reserved(int n);
#define MICROPY_HW_PIN_RESERVED(i) mp_hal_is_pin_reserved(i)
