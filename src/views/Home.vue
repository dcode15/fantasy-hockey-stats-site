<template>
    <v-container>
        <v-card>
            <v-card-title>
                Players
                <div class="flex-grow-1"></div>
                <v-btn @click="scoringDrawerOpen = !scoringDrawerOpen" color="primary" class="mr-10 mt-2">Adjust
                    Scoring
                </v-btn>
                <v-select
                        :items="positions"
                        label="Position"
                        v-model="positionFilter"
                        class="pt-9 pr-6"
                ></v-select>
                <v-text-field
                        v-model="search"
                        label="Search Players by Name"
                        single-line
                        hide-details
                        clearable
                ></v-text-field>
            </v-card-title>
            <v-data-table :headers="headers"
                          sort-by="averagePointsPerGame"
                          sort-desc
                          :items="playersWithCalculations"
                          disable-pagination
                          :search="search"
                          class="elevation-1">
            </v-data-table>
        </v-card>
        <v-navigation-drawer v-model="scoringDrawerOpen" absolute temporary>
            <v-list dense>
                <v-list-item>
                    <v-list-item-content>
                        <v-list-item-title>Skater Scoring
                        </v-list-item-title>
                    </v-list-item-content>
                </v-list-item>
                <v-list-item>
                    <v-list-item-content>
                        <v-text-field
                                v-model="scoring.G"
                                label="Goals"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.A"
                                label="Assists"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.PM"
                                label="+/-"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.PIM"
                                label="Penalty Minutes"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.SHG"
                                label="Shorthanded Goals"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.SOG"
                                label="Shots"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.HIT"
                                label="Hits"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.BLK"
                                label="Blocks"
                        ></v-text-field>
                    </v-list-item-content>
                </v-list-item>
                <v-divider></v-divider>
                <v-list-item>
                    <v-list-item-content>
                        <v-list-item-title>Goalie Scoring
                        </v-list-item-title>
                    </v-list-item-content>
                </v-list-item>
                <v-list-item>
                    <v-list-item-content>
                        <v-text-field
                                v-model="scoring.GS"
                                label="Games Started"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.GA"
                                label="Goals Against"
                        ></v-text-field>
                        <v-text-field
                                v-model="scoring.SV"
                                label="Saves"
                        ></v-text-field>
                    </v-list-item-content>
                </v-list-item>
            </v-list>
        </v-navigation-drawer>
    </v-container>
</template>

<script>
    import playersJSON from '../data/player_data.json'

    export default {
        data: () => ({
            search: null,
            positionFilter: "All",
            playerData: playersJSON,
            scoringDrawerOpen: false,
            positions: [
                "All",
                "Skaters",
                "Forwards",
                "C",
                "LW",
                "RW",
                "D",
                "G"
            ],
            scoring: {
                G: 5,
                A: 2.94,
                PM: 0.66,
                PIM: -0.32,
                SHG: 0.59,
                SOG: 0.45,
                HIT: 0.12,
                BLK: 0.24,
                GS: 5,
                GA: -5,
                SV: 0.45
            },
        }),
        computed: {
            playersWithCalculations: function () {
                return this.playerData.map(player => {
                    let playerData = this.calculatePlayerData(player, true);
                    player = {...player, ...playerData};
                    if (player.info.position.code === "L") {
                        player.info.position.code = "LW";
                    }
                    if (player.info.position.code === "R") {
                        player.info.position.code = "RW";
                    }
                    return player
                });
            },
            headers: function () {
                return [
                    {
                        text: "Name",
                        value: "info.person.fullName",
                        filterable: true
                    },
                    {
                        text: "Position",
                        value: "info.position.code",
                        filter: value => {
                            if (this.positionFilter === "All") {
                                return true;
                            } else if (this.positionFilter === "Skaters") {
                                return value !== "G";
                            } else if (this.positionFilter === "Forwards") {
                                return value === "C" || value === "RW" || value === "LW"
                            } else {
                                return this.positionFilter === value;
                            }
                        }
                    },
                    {
                        text: "Team",
                        value: "team.abbreviation",
                        filterable: false
                    },
                    {
                        text: "PPG",
                        value: "averagePointsPerGame",
                        filterable: false
                    },
                    {
                        text: "2019 Points",
                        value: "yearOneTotal",
                        filterable: false
                    },
                    {
                        text: "2019 PPG",
                        value: "yearOneAvgPPG",
                        filterable: false
                    },
                    {
                        text: "2018 Points",
                        value: "yearTwoTotal",
                        filterable: false
                    },
                    {
                        text: "2018 PPG",
                        value: "yearTwoAvgPPG",
                        filterable: false
                    },
                    {
                        text: "2017 Points",
                        value: "yearThreeTotal",
                        filterable: false
                    },
                    {
                        text: "2017 PPG",
                        value: "yearThreeAvgPPG",
                        filterable: false
                    },
                ]
            }
        },
        methods: {
            calculateScoreTotal: function (position, stats, round_total) {
                let total = 0;

                if (position !== "G") {
                    if (stats !== null) {
                        total = stats.goals * this.scoring.G + stats.assists * this.scoring.A + stats.plusMinus * this.scoring.PM
                            + stats.pim * this.scoring.PIM + stats.shortHandedGoals * this.scoring.SHG
                            + stats.shots * this.scoring.SOG + stats.hits * this.scoring.HIT
                            + stats.blocked * this.scoring.BLK;
                    }
                } else {
                    if (stats !== null) {
                        total = stats.gamesStarted * this.scoring.GS + stats.saves * this.scoring.SV
                            + stats.goalsAgainst * this.scoring.GA
                    }
                }

                if (round_total) {
                    total = Math.round(total);
                }

                return total
            },
            calculatePlayerData: function (player, round_values) {
                let yearOneTotal = this.calculateScoreTotal(player.info.position.code, player.yearOneStats, round_values);
                let yearTwoTotal = this.calculateScoreTotal(player.info.position.code, player.yearTwoStats, round_values);
                let yearThreeTotal = this.calculateScoreTotal(player.info.position.code, player.yearThreeStats, round_values);

                let yearOneGP = 0;
                let yearOneAvgPPG = 0;
                if (player.yearOneStats !== null) {
                    yearOneGP = player.yearOneStats.games;
                    if (yearOneGP > 0) {
                        yearOneAvgPPG = (yearOneTotal / yearOneGP).toFixed(2);
                    }
                }
                let yearTwoGP = 0;
                let yearTwoAvgPPG = 0;
                if (player.yearTwoStats !== null) {
                    yearTwoGP = player.yearTwoStats.games;
                    if (yearTwoGP > 0) {
                        yearTwoAvgPPG = (yearTwoTotal / yearTwoGP).toFixed(2);
                    }
                }
                let yearThreeGP = 0;
                let yearThreeAvgPPG = 0;
                if (player.yearThreeStats !== null) {
                    yearThreeGP = player.yearThreeStats.games;
                    if (yearThreeGP > 0) {
                        yearThreeAvgPPG = (yearThreeTotal / yearThreeGP).toFixed(2);
                    }
                }
                let averagePointsPerGame = 0;
                if (yearOneGP + yearTwoGP + yearThreeGP > 0) {
                    averagePointsPerGame = ((yearOneTotal + yearTwoTotal + yearThreeTotal)
                        / (yearOneGP + yearTwoGP + yearThreeGP)).toFixed(2)
                }

                return {
                    yearOneTotal: yearOneTotal,
                    yearTwoTotal: yearTwoTotal,
                    yearThreeTotal: yearThreeTotal,
                    yearOneGP: yearOneGP,
                    yearTwoGP: yearTwoGP,
                    yearThreeGP: yearThreeGP,
                    yearOneAvgPPG: yearOneAvgPPG,
                    yearTwoAvgPPG: yearTwoAvgPPG,
                    yearThreeAvgPPG: yearThreeAvgPPG,
                    averagePointsPerGame: averagePointsPerGame
                }
            }
        }
    };
</script>

<style>
    tbody tr:nth-of-type(odd) {
        background-color: rgba(0, 0, 0, .05);
    }
</style>