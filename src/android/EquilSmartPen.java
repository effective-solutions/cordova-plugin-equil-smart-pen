package cordova.plugin.equil.smart.pen;

import android.annotation.SuppressLint;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.RectF;
import android.os.Handler;
import android.os.Message;
import android.content.Context;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;


import com.pnf.bt.lib.PNFDefine;
import com.pnf.bt.lib.PNFPenController;
import com.pnf.bt.lib.PenDataClass;
import org.apache.cordova.*;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Timer;
import java.util.TimerTask;

public class EquilSmartPen extends CordovaPlugin {
    String messageReceived;
    private CordovaWebView web;
    private float cordX = 0;
    private float cordY = 0;

    @Override
    public void initialize (CordovaInterface cordova, CordovaWebView webView) {
        this.web = webView;

        Context context = cordova.getActivity().getApplicationContext();
        MainDefine.penController = new PNFPenController(context);
        MainDefine.penController.setDefaultModelCode(PNFDefine.Equil);
        MainDefine.penController.setConnectDelay(false);
        MainDefine.penController.setProjectiveLevel(4);
        MainDefine.penController.fixStationPosition(PNFDefine.DIRECTION_TOP);
        MainDefine.penController.setCalibration(context);

        RectF rectFT_8X5 = new RectF(
                2651 , 458,
                4646 , 3058);

        PointF[] calScreenPoint = new PointF[4];
        PointF[] calResultPoint = new PointF[4];
        calResultPoint[0] = new PointF(rectFT_8X5.left, rectFT_8X5.top);
        calResultPoint[1] = new PointF(rectFT_8X5.right, rectFT_8X5.top);
        calResultPoint[2] = new PointF(rectFT_8X5.right ,rectFT_8X5.bottom);
        calResultPoint[3] = new PointF(rectFT_8X5.left ,rectFT_8X5.bottom);

        calScreenPoint[0] = new PointF(0.0f ,0.0f);
        calScreenPoint[1] = new PointF(300.0f ,0.0f);
        calScreenPoint[2] = new PointF(300.0f ,400.0f);
        calScreenPoint[3] = new PointF(0.0f ,400.0f);

        MainDefine.penController.setCalibrationData(calScreenPoint, 0, calResultPoint);
        MainDefine.penController.startPen();

        MainDefine.penController.SetRetObj(penHandler);
        MainDefine.penController.SetRetObjForMsg(messageHandler);
        System.out.println("plugin initiated");


    }

    @SuppressLint("HandlerLeak")
    Handler penHandler = new Handler()
    {
        @Override
        public void handleMessage(Message msg)
        {
            onPenEvent(msg.what ,msg.arg1 ,msg.arg2 ,msg.obj);
        }
    };

    void onPenEvent(int penState, int RawX, int RawY ,Object obj)
    {
        PenDataClass penData = (PenDataClass)obj;
        PointF ptConv = MainDefine.penController.GetCoordinatePostionXY(RawX ,RawY ,penData.bRight);

        final String message = "["+penState+","+cordX+","+cordY+","+ptConv.x+","+ptConv.y+"]";
        cordX = ptConv.x;
        cordY = ptConv.y;
        sendMessageCallback(message);
    }

    void sendMessageCallback(String message){
        final String text = message;
        cordova.getActivity().runOnUiThread(new Runnable(){
            public void run(){
                web.loadUrl("javascript:window.plugins.EquilSmartPen.onDataReceived("+text+")");
            }
        });
    }

    @SuppressLint("HandlerLeak")
    Handler messageHandler = new Handler()
    {
        @Override
        public void handleMessage(Message msg)
        {
            onMessageEvent(msg.what ,msg.obj);
        }
    };

    void onMessageEvent(int what, Object obj)
    {
        sendEventCallback(Integer.toString(what));
    }

    void sendEventCallback(String message){
        final String text = message;
        cordova.getActivity().runOnUiThread(new Runnable(){
            public void run(){
                web.loadUrl("javascript:window.plugins.EquilSmartPen.onEventReceived('"+text+"')");
            }
        });
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("start")) {
            String message = args.getString(0);
            callbackContext.success(message);
            System.out.println("start method called");
            return true;
        }
        return false;
    }

}
