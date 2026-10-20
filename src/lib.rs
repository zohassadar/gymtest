use pyo3::prelude::*;
mod emu;
pub use emu::*;

#[pymodule]
mod gymtest {
    use crate::run_emulator;
    use pyo3::prelude::*;
    #[pyfunction]
    fn run(rom: Vec<u8>, raminit: Vec<u8>) -> ([u8; 0x800], i32) {
        let rambuffer: &mut [u8; 0x800] = &mut [0; 0x800];
        rambuffer.copy_from_slice(&raminit);
        let cycles = run_emulator(&rom, rambuffer);
        (rambuffer.clone(), cycles)
    }
}
