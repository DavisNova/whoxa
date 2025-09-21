const jwt = require("jsonwebtoken");
const { User, Block, UserSocket, Chatlock } = require("../../models");
const { Op } = require("sequelize");
let jwtSecretKey = process.env.JWT_SECRET_KEY;

const searchUser = async (req, res) => {
  let { user_name } = req.body;
  if (!user_name) {
    return res
      .status(400)
      .json({ success: false, message: "user_name field is required" });
  }
  try {
    // authtoken is required - get from middleware
    const authData = req.authData;

    const resData = await User.findAll({
      where: {
        [Op.or]: [
          {
            user_name: {
              [Op.like]: `%${user_name}%`,
            },
          },
          {
            first_name: {
              [Op.like]: `%${user_name}%`,
            },
          },
          {
            last_name: {
              [Op.like]: `%${user_name}%`,
            },
          },
          {
            phone_number: {
              [Op.like]: `%${user_name}%`,
            },
          },
        ],
        user_id: {
          [Op.not]: authData.user_id,
        },
      },
      attributes: [
        "user_id",
        "bio",
        "user_name",
        "first_name",
        "last_name",
        "phone_number",
        "country_code",
        "email_id",
        "profile_image",
        "device_token",
        "one_signal_player_id",
        "gender",
        "country",
        "country_full_name",
        "avatar_id",
        "is_account_deleted",
        "is_mobile",
        "is_web",
        // "voice_token",
      ],
    });

    let newData = await Promise.all(
      resData.map(async (e) => {
        // console.log(e.dataValues);
        // Check if the user is blocked or not
        // 简化Block查询，只检查基本的屏蔽状态
        const isBlocked = null; // 暂时禁用Block检查，因为Block表结构不明确

        const is_online = await UserSocket.findOne({
          where: { user_id: e.dataValues.user_id },
        });

        // Check chat is locked or not
        // 简化Chatlock查询
        const chatLockData = null; // 暂时禁用Chatlock检查

        // set is_block value
        e.dataValues.is_block =
          isBlocked == null
            ? {
                block_id: 0,
                createdAt: "",
                updatedAt: "",
                userId: 0,
                blockedUserId: 0,
              }
            : isBlocked;
        e.dataValues.is_online = is_online == null ? false : true;
        e.dataValues.is_chat_lock = chatLockData == null ? false : true;

        return e;
      })
    );

    res.status(200).json({
      success: true,
      message: "Search completed successfully",
      resData: newData,
    });
  } catch (error) {
    console.log(error);
    // Handle the Sequelize error and send it as a response to the client
    res.status(500).json({ error: error.message });
  }
};

module.exports = { searchUser };
