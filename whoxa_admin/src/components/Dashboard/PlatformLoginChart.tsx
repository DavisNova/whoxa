import React, { useEffect, useState } from "react";
import ReactApexChart from "react-apexcharts";
import useApiPost from "../../hooks/PostData";

const PlatformActivityChart = () => {
    const { postData } = useApiPost();
    const [series, setSeries] = useState([0, 0, 0]);
    const [counts, setCounts] = useState([0, 0, 0, 0]); // [web, mobile, both, others]
    const [total, setTotal] = useState(0);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await postData('Get-Platform-Activity', {});
                if (response.success && response.result) {
                    const { web, mobile, both, others } = response.result;
                    setCounts([web, mobile, both, others]);

                    const totalCount = web + mobile + both + others;
                    setTotal(totalCount);

                    const webCount = web + both / 2;
                    const mobileCount = mobile + both / 2;

                    const webPercent = (webCount / totalCount) * 100;
                    const mobilePercent = (mobileCount / totalCount) * 100;
                    const othersPercent = (others / totalCount) * 100;

                    setSeries([
                        parseFloat(webPercent.toFixed(2)),
                        parseFloat(mobilePercent.toFixed(2)),
                        // parseFloat(othersPercent.toFixed(2)),
                    ]);
                }
            } catch (error) {
                console.error('Failed to fetch platform activity:', error);
            }
        };

        fetchData();
    }, []);

    const options = {
        chart: {
            type: "donut",
        },
        plotOptions: {
            pie: {
                startAngle: -90,
                endAngle: 90,
                donut: {
                    size: "68%",
                    labels: {
                        show: true,
                        name: {
                            show: true,
                        },
                        value: {
                            show: true,
                            fontSize: "22px",
                            fontWeight: 600,
                            color: "#000",
                            offsetY: 10,
                            formatter: (val, opts) => {
                                return total;
                            },
                        },
                        total: {
                            show: true,
                            label: "Total Users",
                            fontSize: "14px",
                            fontWeight: 500,
                            color: "#888",
                            formatter: function (w) {
                                return "\n\n" +total ; // This adds space visually
                            }
                        },

                    },
                },
            },
        },
        legend: {
            show: false,
        },
        dataLabels: {
            enabled: true,
            formatter: function (val) {
                return val.toFixed(2) + "%";
            },
        },
        tooltip: {
            y: {
                formatter: function () {
                    return "";
                },
            },
            custom: function ({ seriesIndex, w }) {
                return `<div class="apexcharts-tooltip-label"><div>`;
            },
        },
        labels: ["Login by Website", "Login by Mobile"],
        colors: ["#2CD4B2", "#4B9EFF"],
        responsive: [
            {
                breakpoint: 480,
                options: {
                    chart: {
                        width: 200,
                    },
                },
            },
        ],
    };

    return (
        <div className="panel my-4  col-span-2">
            <h2 className="text-xl font-bold  text-pretty text-black dark:text-white  ">Platform Activity</h2>

            <div className="flex flex-col m-auto items-center">
                <ReactApexChart
                    options={options}
                    series={series}
                    type="donut"
                    height={300}
                />

                {/* Labels positioned closer to the chart */}
                <div className=" w-1/3 m-auto grid grid-cols-1 sm:grid-cols-2 gap-y-2 text-sm font-medium text-gray-700 text-center">
                    <div className=" flex items-center gap-2 justify-center">
                        <span className="w-3 h-3 rounded-full bg-[#2CD4B2]"></span>
                        Website:
                        <span className="ml-1 text-black">
                            {(counts[0] + counts[2] / 2).toFixed(0)}
                        </span>
                    </div>
                    <div className="flex items-center gap-2 justify-center">
                        <span className="w-3 h-3 rounded-full bg-[#4B9EFF]"></span>
                        Mobile:
                        <span className="ml-1 text-black">
                            {(counts[1] + counts[2] / 2).toFixed(0)}
                        </span>
                    </div>
                    
                </div>
            </div>
        </div>
    );



};

export default PlatformActivityChart;
