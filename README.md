# cockroach_adjust

MATLAB code and data for:

> **Cockroaches adjust body and appendages to traverse cluttered large obstacles**
>
> Yaqing Wang, Ratan Othayoth, Chen Li\*
>
> Department of Mechanical Engineering, Johns Hopkins University
>
> \*Corresponding author. Email: chen.li@jhu.edu
>
> *Journal of Experimental Biology* (2022) 225, jeb243605. https://doi.org/10.1242/jeb.243605

## Repository layout

```
code/
  analysis/            full processing + landscape pipeline (scripts c1_ ... c34_, run in numeric order)
    Dependences/       shared helper functions (state calculation, BFS, interpolation, superbar)
    BFS_dependences/   breadth-first-search helpers for basin/barrier detection
    FMINSEARCHBND/     third-party bounded fminsearch
  model_construction/  STL -> MATLAB model conversion for the head/thorax/abdomen model
  figures/             final scripts used to draw the figures in the paper
    movies/            scripts used to render frames for the supplementary movies
data/
  kinematics/DataBase.mat     main database: 3D kinematics of all 36 trials (+ trials 37/38, the
                              averaged "ideal" trajectories used for the landscape), phase frames,
                              animal model parameters
  kinematics/DataBase_organized_64.mat  earlier database of all 64 recorded trials, including the 28
                              trials not in the 36-trial dataset (used for the "even counting the 28
                              trials not included" comparison in Results)
  info/Info.xlsx              trial list: animal, frames of each phase, roll direction, etc.
  info/Marker_setting.pptx    marker placement notes
  calibration/                DLT calibration (coefficients + digitized calibration points) per session
  reconstruction/point_data.mat  3D reconstructed marker points (input to the DataBase creator)
  cockroach_model/            SolidWorks parts, STL and .mat of the 3-segment animal model
  statistics/                 per-trial phase averages exported for JMP, JMP tables and JSL script
output/                       created when scripts run (landscapes, frames, plots); not tracked
```

## Requirements

- MATLAB (developed with R2021b)
- JMP 16 for the mixed-effects ANOVAs (`data/statistics/stat_code.jsl`)

## Paths

All paths are relative to the repository root. Each script sets
`REPO = fileparts(fileparts(fileparts(mfilename('fullpath'))));` and builds paths from it, so scripts
can be run from any working directory. Run them as files (Run button or `run('...')`), not by
evaluating a selection, so that `mfilename` resolves. Intermediate and generated results are written
to `output/` (e.g. `output/landscape/<project>/` for the landscape pipeline).

A few scripts at the start of the pipeline (`c1_seq2aviBatchFormerAndCompression.m`, `c3_Tracking.m`,
`c5_reconstruction_tag.m`) still refer to the original raw-recording drive and to the lab's BEEtag
toolbox; they need the raw recordings, which are not included.

## Not included

- **Raw high-speed videos** (8 cameras x 36 trials, ~5 GB) and intermediate tracking files
  (`raw_videos/`, `tracking/` in the scripts).
- **Full landscape outputs for Fig. 10** (`barrier_31`, `barrier_32`, `barrier_33`). These can be
  regenerated with the `c31_*`, `c32_*`, `c33_*` scripts from `DataBase.mat` (the landscape generation
  took ~3 weeks on a 32-core workstation).
- **Landscape outputs for Fig. 4 and Movie 3** (average trajectory, head flexion 15 deg). The scripts in
  `code/figures/movies/` expect them in `data/landscape_examples/<movie name>/` (the pitch-roll
  cross-section in `data/landscape_examples/shared_HD15/`); they are produced by the same landscape
  pipeline.
- **Data from the previous study** (Othayoth et al., 2020, *PNAS*), used only for the comparison of
  traversal time and maximal body roll in Results (`code/figures/previous_study_comparison.m` and
  `stat_generation.m` expect it in `data/previous_study/timeData_V3.mat`). Please obtain it from that
  study.

## Pipeline

1. **Tracking & reconstruction** – `c1`–`c7`: video conversion, BEEtag tracking, merge of DeepLabCut
   leg/abdomen tracking, DLT 3D reconstruction (`c4_*`, `c5_reconstruction_tag.m`).
2. **Kinematics database** – `c8_DataBaseCreator_V3.m` builds `DataBase.mat`;
   `c8_1_ideal_trial_generator.m` builds the average trajectory (trials 37/38).
3. **Potential energy landscape** – for each project: `*_1_Pandora_generator` (computes the landscape;
   ~3 weeks on 32 cores), `*_2_pandora_compress` (collapse along z), `*_3_basin_select_coarse`,
   `*_4_basin_figure` (BFS for minima, saddle point and barrier), `*_5_compare` (plots).
   - `c31_*` (`barrier_31`): pitch-to-roll barrier vs. head flexion -> **Fig. 10A**
   - `c33_*` (`barrier_33`): pitch-to-roll barrier vs. total leg sprawl -> **Fig. 10B**
   - `c32_*` (`barrier_32`): roll-to-deflect (yaw) barrier vs. head flexion -> **Fig. 10C,D**

## Figures and numbers

| Paper item | Script |
|---|---|
| Fig. 5 phase durations, traversal time, max roll | `code/figures/stat_generation.m`, `code/analysis/c25_someStatForThePaper.m` |
| Figs 6–9 B,D (kinematics vs. normalized time) | `code/figures/lineplot_normalizedTime.m` |
| Figs 6–9 C,E (phase averages, bar plots) | `code/figures/barplot.m` |
| Statistics (mixed-effects ANOVA between phases) | `data/statistics/` (`stat_*.csv` -> JMP, `stat_code.jsl`) |
| Comparison with Othayoth et al. 2020 (traversal time, max roll) | `code/figures/previous_study_comparison.m` (needs that study's data, not included) |
| Kinetic energy fluctuation (0.01 mJ) | `code/analysis/c11_delta_KE.m` |
| Hindleg velocity / kinetic energy (0.17 m/s, 0.005 mJ) | `code/figures/leg_energy.m` |
| Beam deflection error, new vs. old model | `code/figures/beam_calculation_difference.m`, `code/analysis/c13_*`, `data/statistics/stat_beam_calculation_difference.xlsx` |
| Body z method comparison (Fig. S2) | `code/analysis/c18_BodyZ_method_comparison.m` |
| Average trajectory (Fig. S2) | `code/analysis/c8_1_ideal_trial_generator.m` |
| Fig. 4 landscape cross-sections | `code/figures/movies/m_*.m` (landscape data not included, see below) |
| Fig. 10 barriers | `code/analysis/c31_5_compare.m`, `c32_4_compare.m`, `c33_5_compare.m` |
| Fig. 10 a–d values (0.0027, 0.06, 0.012, 0.008 mJ) | read off the Fig. 10 curves; summarized in `code/figures/max_save_energy_compare.m` |
| Model figures | `code/figures/animal_model_pose.m`, `animal_demo.m` |
| Supplementary movies | `code/analysis/c30_*`, `c34_*`, `code/figures/movies/` |

Statistical tests were run in JMP 16; all other analyses in MATLAB.

## License

MIT License, see `LICENSE`.
