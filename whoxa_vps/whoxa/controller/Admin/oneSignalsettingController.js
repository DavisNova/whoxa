// to add New app settings
const { Group_Setting, Admin, One_signal_setting } = require("../../models");
const updateEnvVariables = require("../../reusable/updateEnvVariables");

async function checkOneSignalsettingAndCreate() {
  try {
    const isOneSignal = await One_signal_setting.findOne({
      where: { setting_id: 1 },
    });

    if (isOneSignal) {
      return;
    } else {
      await One_signal_setting.create({
        ONESIGNAL_API_KEY: "OnesignalAPIKey",
        ONESIGNAL_APPID: "One signal appid",
      });
    }
  } catch (err) {
    console.log(err);
  }
}
// Edit AppSettings
async function editOneSignalSettings(req, res) {
  try {
    const { admin_id } = req.authData;
    const { setting_id, ONESIGNAL_API_KEY, ONESIGNAL_APPID } = req.body;

    // dynamic payload as per enty

    if (await Admin.findOne({ where: { admin_id } })) {
      if (await One_signal_setting.findOne({ where: { setting_id } })) {
        const editedOneSignalSettings = await One_signal_setting.update(
          { ONESIGNAL_API_KEY, ONESIGNAL_APPID },
          { where: { setting_id } }
        );
        updateEnvVariables({ 
          ONESIGNAL_API_KEY: ONESIGNAL_API_KEY,
          ONESIGNAL_APPID: ONESIGNAL_APPID 
        });
        
        // 更新环境变量后，重启进程以加载新的环境变量
        console.log("OneSignal设置已更新，正在重启进程以应用新的环境变量...");
        res.status(200).json({
          success: true,
          message: "Settings Edited Successfully. Server will restart to apply changes.",
        });
        
        // 延迟重启，确保响应先发送
        setTimeout(() => {
          process.exit(0); // PM2会自动重启进程
        }, 1000);
      } else {
        res.status(404).json({
          success: false,
          message: "Setting Not Found",
        });
      }
    } else {
      res.status(404).json({
        success: false,
        message: "You are Unauthorized for This action",
      });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error in Edit Settings" });
  }
}

async function getOneSignalSetting(req, res) {
  try {
    // console.log(req);

    const settings = await One_signal_setting.findAll();
    res.status(200).json({
      success: true,
      message: "One Signal Setting is",
      settings,
    });
  } catch (err) {
    console.error(err);
    res
      .status(500)
      .json({ error: "Error in listing One Signal Settings from Id" });
  }
}

async function checkGroupsettingAndCreate() {
  try {
    const isGroupSettings = await Group_Setting.findOne({
      where: { setting_id: 1 },
    });

    if (isGroupSettings) {
      return;
    } else {
      await Group_Setting.create({
        max_members: 10,
      });
    }
  } catch (err) {
    console.log(err);
  }
}

// Delete App Setting

module.exports = {
  editOneSignalSettings,
  getOneSignalSetting,
  checkOneSignalsettingAndCreate,
  checkGroupsettingAndCreate,
};
