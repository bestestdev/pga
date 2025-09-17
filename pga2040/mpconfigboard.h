// Board and hardware specific configuration
#define MICROPY_HW_BOARD_NAME                   "PGA2040"

// Portion of onboard flash to reserve for the user filesystem
// PGA2040 has 8MB flash, so reserve 1MiB for the firmware and leave 7MiB
#define MICROPY_HW_FLASH_STORAGE_BYTES          (7 * 1024 * 1024)

// Enable networking for wireless support
#define MICROPY_PY_NETWORK 1
#define MICROPY_PY_NETWORK_CYW43 1
#define MICROPY_PY_LWIP 1
#define MICROPY_PY_NETWORK_HOSTNAME_DEFAULT     "PGA2040"

// CYW43 driver configuration for wireless
#define CYW43_USE_SPI (1)
#define CYW43_LWIP (1)
#define CYW43_GPIO (1)
#define CYW43_SPI_PIO (1)

#define MICROPY_HW_PIN_EXT_COUNT    CYW43_WL_GPIO_COUNT

int mp_hal_is_pin_reserved(int n);
#define MICROPY_HW_PIN_RESERVED(i) mp_hal_is_pin_reserved(i)
