# TherapyChain

A decentralized mental health therapy session tracking and recognition platform for incentivizing therapeutic support on Stacks blockchain.

## Features

- Therapy hour tracking with modality-based validation
- Mental health therapist recognition and reward system
- Therapeutic modality approval and management system
- Contribution-based recognition point calculation
- Comprehensive therapy program statistics

## Smart Contract Functions

### Public Functions
- `launch-therapy-program` - Initialize therapy tracking program
- `approve-modality` - Approve modality for tracking (coordinator only)
- `log-therapy-hours` - Register therapy hours with modality
- `calculate-recognition-points` - Calculate recognition points (coordinator only)
- `claim-therapy-recognition` - Claim therapy recognition rewards

### Read-Only Functions
- `get-therapy-hours` - Get therapist's total hours
- `get-therapist-modality` - Get therapist's modality specialization
- `get-total-therapy-hours` - Get total program hours
- `is-modality-approved` - Check modality approval status
- `get-program-stats` - Get comprehensive program statistics

## Modalities
CBT, DBT, EMDR, Psychodynamic, Humanistic, Family Therapy, etc.

## Usage

Deploy the contract to create a therapy tracking system where mental health professionals can log session hours, earn recognition, and contribute to therapeutic support initiatives.

## License

MIT