/// Code taken from https://github.com/kirjavascript/nestris-tools

use pyo3::prelude::*;
use pyo3::types::{PyBytes, PyTuple};
use emulator_6502::{MOS6502, Interface6502};

pub struct Ram {
    ram: Box<[u8; u16::max_value() as usize + 1]> //The maximum address range of the 6502
}

impl Ram {
    pub fn load_program(&mut self, start: usize, data: &[u8]){
        for (i, value) in data.iter().enumerate() {
            self.ram[start + i] = *value;
        }
    }
}

impl Interface6502 for Ram {
    fn read(&mut self, address: u16) -> u8{
        self.ram[address as usize]
    }

    fn write(&mut self, address: u16, data: u8){
        self.ram[address as usize] = data
    }
}

fn load(prg: &[u8]) -> (MOS6502, Ram) {
    let mut ram = Ram{ ram: Box::new([0; u16::max_value() as usize + 1]) };
    ram.load_program(0x0, &prg.to_vec());

    let mut cpu = MOS6502::new();
    cpu.set_program_counter(0x8000);

    (cpu, ram)
}



pub fn run_emulator( rom: &[u8], rambuffer: &mut [u8]) -> i32 {
    let (mut cpu, mut ram) = load(rom);
    for i in 0..0x800usize {
        let i_u16: u16 = i as u16;
        ram.write(i_u16, rambuffer[i]);
        }
    let mut cycles = 0;
    loop {
        cpu.cycle(&mut ram);
        cycles += 1;
        if ram.read(0xef) == 0xff {
            // eprintln!("Cycles: {:?}", cycles);
            break;
        }
    }
    for i in 0..0x800usize {
        let i_u16: u16 = i as u16;
        rambuffer[i] = ram.read(i_u16);
        }
    return cycles
}

/// Initializes memory with raminit and runs rom through emulator until
/// $EF is written with $FF.  
///
/// No error handling or data integrity checking whatsoever
/// 
/// # Arguments
///
/// * `rom`: Size 0x10000, first instruction at 0x8000
/// * `ram`: Init values size 0x800
///
/// Returns tuple of ram in its finished state and
/// the cycles elapsed
/// 
/// tuple[bytes,int]
#[pyfunction]
fn run(py: Python, rom: Vec<u8>, raminit: Vec<u8>) -> PyObject {
    let rambuffer: &mut[u8; 0x800] = &mut [0; 0x800];
    rambuffer.copy_from_slice(&raminit);
    let cycles = run_emulator(&rom, rambuffer);
    let pycycles = cycles.to_object(py);
    let pybytes = PyBytes::new(py, rambuffer).into();
    PyTuple::new(py, &[pybytes, pycycles]).into()
}

#[pymodule]
fn gymtest(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(run, m)?)?;
    Ok(())
}

