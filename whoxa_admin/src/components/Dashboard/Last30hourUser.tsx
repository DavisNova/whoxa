import { useEffect, useState } from "react";
import useApiPost from "../../hooks/PostData";

const Last30hourUser = () => {
    const { postData } = useApiPost();
    const [totalUsers, setTotalUsers] = useState(0);
    const [countryList, setCountryList] = useState([]);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await postData('Get-Active-Users-last-30-mins', {});
                if (response.success) {
                    setTotalUsers(response.totalActiveUsers || 0);

                    // Slice top 5 countries and filter out empty ones optionally
                    const topCountries = (response.activeCountries || [])
                        .filter(c => c.country) // optionally filter out blank countries
                        .slice(0, 5);

                    setCountryList(topCountries);
                }
            } catch (error) {
                console.error('Failed to fetch platform activity:', error);
            }
        };

        fetchData();
    }, []);

    return (
        <div className="panel my-3  h-full p-0 border-0 overflow-hidden">
            {/* Header */}
            <div className="p-6 bg-gradient-to-r from-yellow-500 to-yellow-200 dark:to-yellow-950 ">
                <div className="text-black dark:text-white flex justify-between items-center">
                    <div className="flex flex-col ">

                        <p className="text-xl">Active Users</p>
                        <span className="text-gray-400">Last 30 Mins</span>
                    </div>
                    <h5 className="ltr:ml-auto rtl:mr-auto text-2xl">
                        <span className="text-white-light">Total: </span>{totalUsers}
                    </h5>
                </div>
            </div>

            {/* Country List */}
            {countryList.length == 0 ? (
                <div
                    className="flex items-center justify-center"
                    style={{ height: "calc(100% - 100px)" }} // Replace 80px with your desired subtraction
                >
                    <div className="text-gray-500 dark:text-gray-400 text-sm">No users</div>
                </div>
            ) : (
                    <ul className="space-y-3">
                        {countryList.map((country, index) => (
                            <li key={index}>
                                <div className="flex justify-between text-[#515365] dark:text-gray-200 my-2 mx-4">
                                    <div className="flex gap-2 items-center">
                                        <img
                                            width="24"
                                            src={`/assets/images/flags/${country.country.substring(0, 2).toUpperCase()}.svg`}
                                            className="max-w-none"
                                            alt="flag"
                                        />
                                        <span>{country.country || 'Unknown'}</span>
                                    </div>
                                    <span>{country.count}</span>
                                </div>

                                {/* Yellow underline with side margin */}
                                <div className="w-full h-1">
                                    <div className="bg-yellow-400 mt-1 mx-4 rounded h-0.5"></div>
                                </div>
                            </li>
                        ))}
                    </ul>

            )}
        </div>
    );
};

export default Last30hourUser;
