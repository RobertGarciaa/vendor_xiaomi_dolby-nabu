.class public Lmiui/util/ITouchFeature;
.super Ljava/lang/Object;
.source "ITouchFeature.java"


# static fields
.field private static final DEFAULT:Ljava/lang/String; = "default"

.field private static final GET_MODE_CUR_VALUE:I = 0x2

.field private static final GET_MODE_DEF_VALUE:I = 0x5

.field private static final GET_MODE_MAX_VALUE:I = 0x3

.field private static final GET_MODE_MIN_VALUE:I = 0x4

.field private static final GET_MODE_VALUES:I = 0x7

.field private static volatile INSTANCE:Lmiui/util/ITouchFeature; = null

.field private static final MODE_RESET:I = 0x6

.field private static final SERVICE_NAME_V1:Ljava/lang/String; = "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

.field private static final SERVICE_NAME_V2:Ljava/lang/String; = "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

.field public static final SERVICE_VERSION_CODE_NONE:I = 0x0

.field public static final SERVICE_VERSION_CODE_V1:I = 0x1

.field public static final SERVICE_VERSION_CODE_V2:I = 0x2

.field private static final SET_MODE_EDGE_VALUE:I = 0x8

.field private static final SET_MODE_VALUE:I = 0x1

.field private static final TAG:Ljava/lang/String; = "ITouchFeature"

.field private static final TOUCHFEATURE_DOUBLE_TAP:I = 0x1

.field private static final TOUCHFEATURE_DRIVER_DEBUGLEVEL:I = 0x8

.field private static final TOUCHFEATURE_EDGE_MODE:I = 0x4

.field private static final TOUCHFEATURE_GLOBAL_TOUCH_DIRECTION:I = 0x2

.field private static final TOUCHFEATURE_REMOVE_EDGE_SETTINGS:I = 0x40

.field public static final TOUCH_ACTIVE_MODE:I = 0x1

.field public static final TOUCH_DEBUG_LEVEL:I = 0x12

.field public static final TOUCH_DOUBLETAP_MODE:I = 0xe

.field public static final TOUCH_EDGE_FILTER:I = 0x7

.field public static final TOUCH_EDGE_MODE:I = 0xf

.field public static final TOUCH_GAME_MODE:I = 0x0

.field public static final TOUCH_ID_PRIMARY:I = 0x0

.field public static final TOUCH_ID_SECONDARY:I = 0x1

.field public static final TOUCH_MODE_DIRECTION:I = 0x8

.field public static final TOUCH_PASSIVE_PEN_MODE:I = 0x17

.field public static final TOUCH_PERFORMANCE_MODE:I = 0x15

.field public static final TOUCH_STYLUS_HOPPING_MODE:I = 0x16

.field public static final TOUCH_STYLUS_MODE:I = 0x14

.field public static final TOUCH_STYLUS_QUICK_NOTE_MODE:I = 0x18

.field public static final TOUCH_TOLERANCE:I = 0x3

.field public static final TOUCH_UP_THRESHOLD:I = 0x2

.field public static final TOUCH_WGH_MAX:I = 0x5

.field public static final TOUCH_WGH_MIN:I = 0x4

.field public static final TOUCH_WGH_STEP:I = 0x6


# instance fields
.field private mServiceVersion:I

.field private mTouchFeatureProperties:I


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 69
    const/4 v0, 0x0

    sput-object v0, Lmiui/util/ITouchFeature;->INSTANCE:Lmiui/util/ITouchFeature;

    return-void
.end method

.method private constructor <init>()V
    .registers 3

    .line 115
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 65
    const/4 v0, 0x0

    iput v0, p0, Lmiui/util/ITouchFeature;->mServiceVersion:I

    .line 116
    const-string v1, "ro.vendor.touchfeature.type"

    invoke-static {v1, v0}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0

    iput v0, p0, Lmiui/util/ITouchFeature;->mTouchFeatureProperties:I

    .line 117
    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v0

    iput v0, p0, Lmiui/util/ITouchFeature;->mServiceVersion:I

    .line 118
    return-void
.end method

.method public static getInstance()Lmiui/util/ITouchFeature;
    .registers 2

    .line 72
    sget-object v0, Lmiui/util/ITouchFeature;->INSTANCE:Lmiui/util/ITouchFeature;

    if-nez v0, :cond_17

    .line 73
    const-class v0, Lmiui/util/ITouchFeature;

    monitor-enter v0

    .line 74
    :try_start_7
    sget-object v1, Lmiui/util/ITouchFeature;->INSTANCE:Lmiui/util/ITouchFeature;

    if-nez v1, :cond_12

    .line 75
    new-instance v1, Lmiui/util/ITouchFeature;

    invoke-direct {v1}, Lmiui/util/ITouchFeature;-><init>()V

    sput-object v1, Lmiui/util/ITouchFeature;->INSTANCE:Lmiui/util/ITouchFeature;

    .line 77
    :cond_12
    monitor-exit v0

    goto :goto_17

    :catchall_14
    move-exception v1

    monitor-exit v0
    :try_end_16
    .catchall {:try_start_7 .. :try_end_16} :catchall_14

    throw v1

    .line 79
    :cond_17
    :goto_17
    sget-object v0, Lmiui/util/ITouchFeature;->INSTANCE:Lmiui/util/ITouchFeature;

    return-object v0
.end method


# virtual methods
.method public getModeValues(I)[I
    .registers 11
    .param p1, "mode"    # I

    .line 552
    const-string v0, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .line 554
    .local v2, "hidl_reply":Landroid/os/HwParcel;
    :try_start_9
    const-string v3, "default"

    invoke-static {v0, v3}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v3

    .line 555
    .local v3, "hwService":Landroid/os/IHwBinder;
    if-eqz v3, :cond_48

    .line 556
    new-instance v4, Landroid/os/HwParcel;

    invoke-direct {v4}, Landroid/os/HwParcel;-><init>()V

    .line 557
    .local v4, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v4, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 558
    invoke-virtual {v4, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 559
    const/4 v0, 0x7

    const/4 v5, 0x0

    invoke-interface {v3, v0, v4, v2, v5}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 560
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 561
    invoke-virtual {v4}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 562
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32Vector()Ljava/util/ArrayList;

    move-result-object v0

    .line 563
    .local v0, "val":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/Integer;>;"
    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I

    move-result v5

    .line 564
    .local v5, "n":I
    new-array v6, v5, [I

    .line 565
    .local v6, "array":[I
    const/4 v7, 0x0

    .local v7, "i":I
    :goto_32
    if-ge v7, v5, :cond_43

    .line 566
    invoke-virtual {v0, v7}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/lang/Integer;

    invoke-virtual {v8}, Ljava/lang/Integer;->intValue()I

    move-result v8

    aput v8, v6, v7
    :try_end_40
    .catch Landroid/os/RemoteException; {:try_start_9 .. :try_end_40} :catch_59
    .catch Ljava/util/NoSuchElementException; {:try_start_9 .. :try_end_40} :catch_4f
    .catchall {:try_start_9 .. :try_end_40} :catchall_4d

    .line 565
    add-int/lit8 v7, v7, 0x1

    goto :goto_32

    .line 568
    .end local v7    # "i":I
    :cond_43
    nop

    .line 575
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 568
    return-object v6

    .line 575
    .end local v0    # "val":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/Integer;>;"
    .end local v3    # "hwService":Landroid/os/IHwBinder;
    .end local v4    # "hidl_request":Landroid/os/HwParcel;
    .end local v5    # "n":I
    .end local v6    # "array":[I
    :cond_48
    nop

    :goto_49
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 576
    goto :goto_72

    .line 575
    :catchall_4d
    move-exception v0

    goto :goto_7b

    .line 572
    :catch_4f
    move-exception v0

    .line 573
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_50
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v1, v3}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 575
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_49

    .line 570
    :catch_59
    move-exception v0

    .line 571
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "transact failed. "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v1, v3}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_70
    .catchall {:try_start_50 .. :try_end_70} :catchall_4d

    .line 575
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_49

    .line 577
    :goto_72
    const-string v0, "getModeValues failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 578
    const/4 v0, 0x4

    new-array v0, v0, [I

    return-object v0

    .line 575
    :goto_7b
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 576
    throw v0
.end method

.method public getModeValues(II)[I
    .registers 13
    .param p1, "touchId"    # I
    .param p2, "mode"    # I

    .line 592
    const-string v0, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v2

    const/4 v3, 0x4

    packed-switch v2, :pswitch_data_92

    .line 600
    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .local v2, "hidl_reply":Landroid/os/HwParcel;
    goto :goto_1a

    .line 596
    .end local v2    # "hidl_reply":Landroid/os/HwParcel;
    :pswitch_12
    invoke-virtual {p0, p2}, Lmiui/util/ITouchFeature;->getModeValues(I)[I

    move-result-object v0

    return-object v0

    .line 594
    :pswitch_17
    new-array v0, v3, [I

    return-object v0

    .line 602
    .restart local v2    # "hidl_reply":Landroid/os/HwParcel;
    :goto_1a
    :try_start_1a
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 603
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_5c

    .line 604
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 605
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 606
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 607
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 608
    const/4 v0, 0x7

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 609
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 610
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 611
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32Vector()Ljava/util/ArrayList;

    move-result-object v0

    .line 612
    .local v0, "val":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/Integer;>;"
    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I

    move-result v6

    .line 613
    .local v6, "n":I
    new-array v7, v6, [I

    .line 614
    .local v7, "array":[I
    const/4 v8, 0x0

    .local v8, "i":I
    :goto_46
    if-ge v8, v6, :cond_57

    .line 615
    invoke-virtual {v0, v8}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v9

    check-cast v9, Ljava/lang/Integer;

    invoke-virtual {v9}, Ljava/lang/Integer;->intValue()I

    move-result v9

    aput v9, v7, v8
    :try_end_54
    .catch Landroid/os/RemoteException; {:try_start_1a .. :try_end_54} :catch_6d
    .catch Ljava/util/NoSuchElementException; {:try_start_1a .. :try_end_54} :catch_63
    .catchall {:try_start_1a .. :try_end_54} :catchall_61

    .line 614
    add-int/lit8 v8, v8, 0x1

    goto :goto_46

    .line 617
    .end local v8    # "i":I
    :cond_57
    nop

    .line 624
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 617
    return-object v7

    .line 624
    .end local v0    # "val":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/Integer;>;"
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    .end local v6    # "n":I
    .end local v7    # "array":[I
    :cond_5c
    nop

    :goto_5d
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 625
    goto :goto_86

    .line 624
    :catchall_61
    move-exception v0

    goto :goto_8e

    .line 621
    :catch_63
    move-exception v0

    .line 622
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_64
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 624
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_5d

    .line 619
    :catch_6d
    move-exception v0

    .line 620
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_84
    .catchall {:try_start_64 .. :try_end_84} :catchall_61

    .line 624
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_5d

    .line 626
    :goto_86
    const-string v0, "getModeValues failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 627
    new-array v0, v3, [I

    return-object v0

    .line 624
    :goto_8e
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 625
    throw v0

    :pswitch_data_92
    .packed-switch 0x0
        :pswitch_17
        :pswitch_12
    .end packed-switch
.end method

.method public getSupportTouchFeatureVersion()I
    .registers 5

    .line 83
    const-string v0, "default"

    iget v1, p0, Lmiui/util/ITouchFeature;->mServiceVersion:I

    const-string v2, "ITouchFeature"

    if-eqz v1, :cond_23

    .line 84
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "current device and process support version:"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lmiui/util/ITouchFeature;->mServiceVersion:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 85
    iget v0, p0, Lmiui/util/ITouchFeature;->mServiceVersion:I

    return v0

    .line 88
    :cond_23
    :try_start_23
    const-string v1, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    invoke-static {v1, v0}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v1

    .line 89
    .local v1, "hwService2":Landroid/os/IHwBinder;
    if-eqz v1, :cond_32

    .line 90
    const-string v3, "current device and process support v2 service"

    invoke-static {v2, v3}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_30
    .catch Landroid/os/RemoteException; {:try_start_23 .. :try_end_30} :catch_3c
    .catch Ljava/util/NoSuchElementException; {:try_start_23 .. :try_end_30} :catch_33

    .line 91
    const/4 v0, 0x2

    return v0

    .line 89
    .end local v1    # "hwService2":Landroid/os/IHwBinder;
    :cond_32
    goto :goto_40

    .line 95
    :catch_33
    move-exception v1

    .line 96
    .local v1, "e":Ljava/util/NoSuchElementException;
    invoke-virtual {v1}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_41

    .line 93
    .end local v1    # "e":Ljava/util/NoSuchElementException;
    :catch_3c
    move-exception v1

    .line 94
    .local v1, "e":Landroid/os/RemoteException;
    invoke-virtual {v1}, Landroid/os/RemoteException;->printStackTrace()V

    .line 97
    .end local v1    # "e":Landroid/os/RemoteException;
    :goto_40
    nop

    .line 100
    :goto_41
    :try_start_41
    const-string v1, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    invoke-static {v1, v0}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v0

    .line 101
    .local v0, "hwService1":Landroid/os/IHwBinder;
    if-eqz v0, :cond_50

    .line 102
    const-string v1, "current device and process support v1 service"

    invoke-static {v2, v1}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_4e
    .catch Landroid/os/RemoteException; {:try_start_41 .. :try_end_4e} :catch_5a
    .catch Ljava/util/NoSuchElementException; {:try_start_41 .. :try_end_4e} :catch_51

    .line 103
    const/4 v1, 0x1

    return v1

    .line 101
    .end local v0    # "hwService1":Landroid/os/IHwBinder;
    :cond_50
    goto :goto_5e

    .line 107
    :catch_51
    move-exception v0

    .line 108
    .local v0, "e":Ljava/util/NoSuchElementException;
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v2, v1}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_5f

    .line 105
    .end local v0    # "e":Ljava/util/NoSuchElementException;
    :catch_5a
    move-exception v0

    .line 106
    .local v0, "e":Landroid/os/RemoteException;
    invoke-virtual {v0}, Landroid/os/RemoteException;->printStackTrace()V

    .line 109
    .end local v0    # "e":Landroid/os/RemoteException;
    :goto_5e
    nop

    .line 111
    :goto_5f
    const-string v0, "current device and process not support, v1/v2 service not found"

    invoke-static {v2, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 112
    const/4 v0, 0x0

    return v0
.end method

.method public getTouchModeCurValue(I)I
    .registers 10
    .param p1, "mode"    # I

    .line 231
    const-string v0, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .line 233
    .local v2, "hidl_reply":Landroid/os/HwParcel;
    const/4 v3, -0x1

    :try_start_a
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 234
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_4e

    .line 235
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 236
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 237
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 238
    const/4 v0, 0x2

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 239
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 240
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 241
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 242
    .local v0, "val":I
    if-gez v0, :cond_49

    .line 243
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getTouchModeCurValue failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_44
    .catch Landroid/os/RemoteException; {:try_start_a .. :try_end_44} :catch_5f
    .catch Ljava/util/NoSuchElementException; {:try_start_a .. :try_end_44} :catch_55
    .catchall {:try_start_a .. :try_end_44} :catchall_53

    .line 244
    nop

    .line 253
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 244
    return v3

    .line 246
    :cond_49
    nop

    .line 253
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 246
    return v0

    .line 253
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_4e
    nop

    :goto_4f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 254
    goto :goto_78

    .line 253
    :catchall_53
    move-exception v0

    goto :goto_7e

    .line 250
    :catch_55
    move-exception v0

    .line 251
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_56
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 253
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_4f

    .line 248
    :catch_5f
    move-exception v0

    .line 249
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_76
    .catchall {:try_start_56 .. :try_end_76} :catchall_53

    .line 253
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_4f

    .line 255
    :goto_78
    const-string v0, "getTouchModeCurValue failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 256
    return v3

    .line 253
    :goto_7e
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 254
    throw v0
.end method

.method public getTouchModeCurValue(II)I
    .registers 11
    .param p1, "touchId"    # I
    .param p2, "mode"    # I

    .line 266
    const-string v0, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v2

    const/4 v3, -0x1

    packed-switch v2, :pswitch_data_94

    .line 274
    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .local v2, "hidl_reply":Landroid/os/HwParcel;
    goto :goto_18

    .line 270
    .end local v2    # "hidl_reply":Landroid/os/HwParcel;
    :pswitch_12
    invoke-virtual {p0, p2}, Lmiui/util/ITouchFeature;->getTouchModeCurValue(I)I

    move-result v0

    return v0

    .line 268
    :pswitch_17
    return v3

    .line 276
    .restart local v2    # "hidl_reply":Landroid/os/HwParcel;
    :goto_18
    :try_start_18
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 277
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_5f

    .line 278
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 279
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 280
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 281
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 282
    const/4 v0, 0x2

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 283
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 284
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 285
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 286
    .local v0, "val":I
    if-gez v0, :cond_5a

    .line 287
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getTouchModeCurValue failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_55
    .catch Landroid/os/RemoteException; {:try_start_18 .. :try_end_55} :catch_70
    .catch Ljava/util/NoSuchElementException; {:try_start_18 .. :try_end_55} :catch_66
    .catchall {:try_start_18 .. :try_end_55} :catchall_64

    .line 288
    nop

    .line 297
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 288
    return v3

    .line 290
    :cond_5a
    nop

    .line 297
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 290
    return v0

    .line 297
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_5f
    nop

    :goto_60
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 298
    goto :goto_89

    .line 297
    :catchall_64
    move-exception v0

    goto :goto_8f

    .line 294
    :catch_66
    move-exception v0

    .line 295
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_67
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 297
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_60

    .line 292
    :catch_70
    move-exception v0

    .line 293
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_87
    .catchall {:try_start_67 .. :try_end_87} :catchall_64

    .line 297
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_60

    .line 299
    :goto_89
    const-string v0, "getTouchModeCurValue failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 300
    return v3

    .line 297
    :goto_8f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 298
    throw v0

    nop

    :pswitch_data_94
    .packed-switch 0x0
        :pswitch_17
        :pswitch_12
    .end packed-switch
.end method

.method public getTouchModeDefValue(I)I
    .registers 10
    .param p1, "mode"    # I

    .line 469
    const-string v0, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .line 471
    .local v2, "hidl_reply":Landroid/os/HwParcel;
    const/4 v3, -0x1

    :try_start_a
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 472
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_4e

    .line 473
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 474
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 475
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 476
    const/4 v0, 0x5

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 477
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 478
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 479
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 480
    .local v0, "val":I
    if-gez v0, :cond_49

    .line 481
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getTouchModeDefValue failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_44
    .catch Landroid/os/RemoteException; {:try_start_a .. :try_end_44} :catch_5f
    .catch Ljava/util/NoSuchElementException; {:try_start_a .. :try_end_44} :catch_55
    .catchall {:try_start_a .. :try_end_44} :catchall_53

    .line 482
    nop

    .line 491
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 482
    return v3

    .line 484
    :cond_49
    nop

    .line 491
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 484
    return v0

    .line 491
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_4e
    nop

    :goto_4f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 492
    goto :goto_78

    .line 491
    :catchall_53
    move-exception v0

    goto :goto_7e

    .line 488
    :catch_55
    move-exception v0

    .line 489
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_56
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 491
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_4f

    .line 486
    :catch_5f
    move-exception v0

    .line 487
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_76
    .catchall {:try_start_56 .. :try_end_76} :catchall_53

    .line 491
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_4f

    .line 493
    :goto_78
    const-string v0, "getTouchModeDefValue failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 494
    return v3

    .line 491
    :goto_7e
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 492
    throw v0
.end method

.method public getTouchModeDefValue(II)I
    .registers 11
    .param p1, "touchId"    # I
    .param p2, "mode"    # I

    .line 504
    const-string v0, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v2

    const/4 v3, -0x1

    packed-switch v2, :pswitch_data_94

    .line 512
    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .local v2, "hidl_reply":Landroid/os/HwParcel;
    goto :goto_18

    .line 508
    .end local v2    # "hidl_reply":Landroid/os/HwParcel;
    :pswitch_12
    invoke-virtual {p0, p2}, Lmiui/util/ITouchFeature;->getTouchModeDefValue(I)I

    move-result v0

    return v0

    .line 506
    :pswitch_17
    return v3

    .line 514
    .restart local v2    # "hidl_reply":Landroid/os/HwParcel;
    :goto_18
    :try_start_18
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 515
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_5f

    .line 516
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 517
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 518
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 519
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 520
    const/4 v0, 0x5

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 521
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 522
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 523
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 524
    .local v0, "val":I
    if-gez v0, :cond_5a

    .line 525
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getTouchModeDefValue failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_55
    .catch Landroid/os/RemoteException; {:try_start_18 .. :try_end_55} :catch_70
    .catch Ljava/util/NoSuchElementException; {:try_start_18 .. :try_end_55} :catch_66
    .catchall {:try_start_18 .. :try_end_55} :catchall_64

    .line 526
    nop

    .line 535
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 526
    return v3

    .line 528
    :cond_5a
    nop

    .line 535
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 528
    return v0

    .line 535
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_5f
    nop

    :goto_60
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 536
    goto :goto_89

    .line 535
    :catchall_64
    move-exception v0

    goto :goto_8f

    .line 532
    :catch_66
    move-exception v0

    .line 533
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_67
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 535
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_60

    .line 530
    :catch_70
    move-exception v0

    .line 531
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_87
    .catchall {:try_start_67 .. :try_end_87} :catchall_64

    .line 535
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_60

    .line 537
    :goto_89
    const-string v0, "getTouchModeDefValue failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 538
    return v3

    .line 535
    :goto_8f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 536
    throw v0

    nop

    :pswitch_data_94
    .packed-switch 0x0
        :pswitch_17
        :pswitch_12
    .end packed-switch
.end method

.method public getTouchModeMaxValue(I)I
    .registers 10
    .param p1, "mode"    # I

    .line 311
    const-string v0, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .line 313
    .local v2, "hidl_reply":Landroid/os/HwParcel;
    const/4 v3, -0x1

    :try_start_a
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 314
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_4e

    .line 315
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 316
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 317
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 318
    const/4 v0, 0x3

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 319
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 320
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 321
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 322
    .local v0, "val":I
    if-gez v0, :cond_49

    .line 323
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getTouchModeMaxValue failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_44
    .catch Landroid/os/RemoteException; {:try_start_a .. :try_end_44} :catch_5f
    .catch Ljava/util/NoSuchElementException; {:try_start_a .. :try_end_44} :catch_55
    .catchall {:try_start_a .. :try_end_44} :catchall_53

    .line 324
    nop

    .line 333
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 324
    return v3

    .line 326
    :cond_49
    nop

    .line 333
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 326
    return v0

    .line 333
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_4e
    nop

    :goto_4f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 334
    goto :goto_78

    .line 333
    :catchall_53
    move-exception v0

    goto :goto_7e

    .line 330
    :catch_55
    move-exception v0

    .line 331
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_56
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 333
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_4f

    .line 328
    :catch_5f
    move-exception v0

    .line 329
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_76
    .catchall {:try_start_56 .. :try_end_76} :catchall_53

    .line 333
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_4f

    .line 335
    :goto_78
    const-string v0, "getTouchModeMaxValue failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 336
    return v3

    .line 333
    :goto_7e
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 334
    throw v0
.end method

.method public getTouchModeMaxValue(II)I
    .registers 11
    .param p1, "touchId"    # I
    .param p2, "mode"    # I

    .line 346
    const-string v0, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v2

    const/4 v3, -0x1

    packed-switch v2, :pswitch_data_94

    .line 354
    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .local v2, "hidl_reply":Landroid/os/HwParcel;
    goto :goto_18

    .line 350
    .end local v2    # "hidl_reply":Landroid/os/HwParcel;
    :pswitch_12
    invoke-virtual {p0, p2}, Lmiui/util/ITouchFeature;->getTouchModeMaxValue(I)I

    move-result v0

    return v0

    .line 348
    :pswitch_17
    return v3

    .line 356
    .restart local v2    # "hidl_reply":Landroid/os/HwParcel;
    :goto_18
    :try_start_18
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 357
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_5f

    .line 358
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 359
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 360
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 361
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 362
    const/4 v0, 0x3

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 363
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 364
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 365
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 366
    .local v0, "val":I
    if-gez v0, :cond_5a

    .line 367
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getTouchModeMaxValue failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_55
    .catch Landroid/os/RemoteException; {:try_start_18 .. :try_end_55} :catch_70
    .catch Ljava/util/NoSuchElementException; {:try_start_18 .. :try_end_55} :catch_66
    .catchall {:try_start_18 .. :try_end_55} :catchall_64

    .line 368
    nop

    .line 377
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 368
    return v3

    .line 370
    :cond_5a
    nop

    .line 377
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 370
    return v0

    .line 377
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_5f
    nop

    :goto_60
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 378
    goto :goto_89

    .line 377
    :catchall_64
    move-exception v0

    goto :goto_8f

    .line 374
    :catch_66
    move-exception v0

    .line 375
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_67
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 377
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_60

    .line 372
    :catch_70
    move-exception v0

    .line 373
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_87
    .catchall {:try_start_67 .. :try_end_87} :catchall_64

    .line 377
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_60

    .line 379
    :goto_89
    const-string v0, "getTouchModeMaxValue failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 380
    return v3

    .line 377
    :goto_8f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 378
    throw v0

    nop

    :pswitch_data_94
    .packed-switch 0x0
        :pswitch_17
        :pswitch_12
    .end packed-switch
.end method

.method public getTouchModeMinValue(I)I
    .registers 10
    .param p1, "mode"    # I

    .line 390
    const-string v0, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .line 392
    .local v2, "hidl_reply":Landroid/os/HwParcel;
    const/4 v3, -0x1

    :try_start_a
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 393
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_4e

    .line 394
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 395
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 396
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 397
    const/4 v0, 0x4

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 398
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 399
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 400
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 401
    .local v0, "val":I
    if-gez v0, :cond_49

    .line 402
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getTouchModeMinValue failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_44
    .catch Landroid/os/RemoteException; {:try_start_a .. :try_end_44} :catch_5f
    .catch Ljava/util/NoSuchElementException; {:try_start_a .. :try_end_44} :catch_55
    .catchall {:try_start_a .. :try_end_44} :catchall_53

    .line 403
    nop

    .line 412
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 403
    return v3

    .line 405
    :cond_49
    nop

    .line 412
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 405
    return v0

    .line 412
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_4e
    nop

    :goto_4f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 413
    goto :goto_78

    .line 412
    :catchall_53
    move-exception v0

    goto :goto_7e

    .line 409
    :catch_55
    move-exception v0

    .line 410
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_56
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 412
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_4f

    .line 407
    :catch_5f
    move-exception v0

    .line 408
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_76
    .catchall {:try_start_56 .. :try_end_76} :catchall_53

    .line 412
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_4f

    .line 414
    :goto_78
    const-string v0, "getTouchModeMinValue failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 415
    return v3

    .line 412
    :goto_7e
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 413
    throw v0
.end method

.method public getTouchModeMinValue(II)I
    .registers 11
    .param p1, "touchId"    # I
    .param p2, "mode"    # I

    .line 425
    const-string v0, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v2

    const/4 v3, -0x1

    packed-switch v2, :pswitch_data_94

    .line 433
    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .local v2, "hidl_reply":Landroid/os/HwParcel;
    goto :goto_18

    .line 429
    .end local v2    # "hidl_reply":Landroid/os/HwParcel;
    :pswitch_12
    invoke-virtual {p0, p2}, Lmiui/util/ITouchFeature;->getTouchModeMinValue(I)I

    move-result v0

    return v0

    .line 427
    :pswitch_17
    return v3

    .line 435
    .restart local v2    # "hidl_reply":Landroid/os/HwParcel;
    :goto_18
    :try_start_18
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 436
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_5f

    .line 437
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 438
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 439
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 440
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 441
    const/4 v0, 0x4

    const/4 v6, 0x0

    invoke-interface {v4, v0, v5, v2, v6}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 442
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 443
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 444
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 445
    .local v0, "val":I
    if-gez v0, :cond_5a

    .line 446
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getTouchModeMinValue failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_55
    .catch Landroid/os/RemoteException; {:try_start_18 .. :try_end_55} :catch_70
    .catch Ljava/util/NoSuchElementException; {:try_start_18 .. :try_end_55} :catch_66
    .catchall {:try_start_18 .. :try_end_55} :catchall_64

    .line 447
    nop

    .line 456
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 447
    return v3

    .line 449
    :cond_5a
    nop

    .line 456
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 449
    return v0

    .line 456
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_5f
    nop

    :goto_60
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 457
    goto :goto_89

    .line 456
    :catchall_64
    move-exception v0

    goto :goto_8f

    .line 453
    :catch_66
    move-exception v0

    .line 454
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_67
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 456
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_60

    .line 451
    :catch_70
    move-exception v0

    .line 452
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_87
    .catchall {:try_start_67 .. :try_end_87} :catchall_64

    .line 456
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_60

    .line 458
    :goto_89
    const-string v0, "getTouchModeMinValue failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 459
    return v3

    .line 456
    :goto_8f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 457
    throw v0

    nop

    :pswitch_data_94
    .packed-switch 0x0
        :pswitch_17
        :pswitch_12
    .end packed-switch
.end method

.method public hasDoubleTapWakeUpSupport()Z
    .registers 3

    .line 121
    iget v0, p0, Lmiui/util/ITouchFeature;->mTouchFeatureProperties:I

    const/4 v1, 0x1

    and-int/2addr v0, v1

    if-eqz v0, :cond_7

    goto :goto_8

    :cond_7
    const/4 v1, 0x0

    :goto_8
    return v1
.end method

.method public hasDriverDebugLevelSupport()Z
    .registers 2

    .line 138
    iget v0, p0, Lmiui/util/ITouchFeature;->mTouchFeatureProperties:I

    and-int/lit8 v0, v0, 0x8

    if-eqz v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public hasSupportEdgeMode()Z
    .registers 2

    .line 130
    iget v0, p0, Lmiui/util/ITouchFeature;->mTouchFeatureProperties:I

    and-int/lit8 v0, v0, 0x4

    if-eqz v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public hasSupportGlobalTouchDirection()Z
    .registers 2

    .line 126
    iget v0, p0, Lmiui/util/ITouchFeature;->mTouchFeatureProperties:I

    and-int/lit8 v0, v0, 0x2

    if-eqz v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public resetTouchMode(I)Z
    .registers 10
    .param p1, "mode"    # I

    .line 637
    const-string v0, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .line 639
    .local v2, "hidl_reply":Landroid/os/HwParcel;
    const/4 v3, 0x0

    :try_start_a
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 640
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_4d

    .line 641
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 642
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 643
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 644
    const/4 v0, 0x6

    invoke-interface {v4, v0, v5, v2, v3}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 645
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 646
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 647
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 648
    .local v0, "val":I
    if-eqz v0, :cond_48

    .line 649
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "resetTouchMode failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_43
    .catch Landroid/os/RemoteException; {:try_start_a .. :try_end_43} :catch_5e
    .catch Ljava/util/NoSuchElementException; {:try_start_a .. :try_end_43} :catch_54
    .catchall {:try_start_a .. :try_end_43} :catchall_52

    .line 650
    nop

    .line 659
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 650
    return v3

    .line 652
    :cond_48
    const/4 v1, 0x1

    .line 659
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 652
    return v1

    .line 659
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_4d
    nop

    :goto_4e
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 660
    goto :goto_77

    .line 659
    :catchall_52
    move-exception v0

    goto :goto_7d

    .line 656
    :catch_54
    move-exception v0

    .line 657
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_55
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 659
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_4e

    .line 654
    :catch_5e
    move-exception v0

    .line 655
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_75
    .catchall {:try_start_55 .. :try_end_75} :catchall_52

    .line 659
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_4e

    .line 661
    :goto_77
    const-string v0, "resetTouchMode failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 662
    return v3

    .line 659
    :goto_7d
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 660
    throw v0
.end method

.method public resetTouchMode(II)Z
    .registers 11
    .param p1, "touchId"    # I
    .param p2, "mode"    # I

    .line 672
    const-string v0, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v2

    const/4 v3, 0x0

    packed-switch v2, :pswitch_data_92

    .line 680
    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .local v2, "hidl_reply":Landroid/os/HwParcel;
    goto :goto_18

    .line 676
    .end local v2    # "hidl_reply":Landroid/os/HwParcel;
    :pswitch_12
    invoke-virtual {p0, p2}, Lmiui/util/ITouchFeature;->resetTouchMode(I)Z

    move-result v0

    return v0

    .line 674
    :pswitch_17
    return v3

    .line 682
    .restart local v2    # "hidl_reply":Landroid/os/HwParcel;
    :goto_18
    :try_start_18
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 683
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_5e

    .line 684
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 685
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 686
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 687
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 688
    const/4 v0, 0x6

    invoke-interface {v4, v0, v5, v2, v3}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 689
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 690
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 691
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 692
    .local v0, "val":I
    if-eqz v0, :cond_59

    .line 693
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "resetTouchMode failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_54
    .catch Landroid/os/RemoteException; {:try_start_18 .. :try_end_54} :catch_6f
    .catch Ljava/util/NoSuchElementException; {:try_start_18 .. :try_end_54} :catch_65
    .catchall {:try_start_18 .. :try_end_54} :catchall_63

    .line 694
    nop

    .line 703
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 694
    return v3

    .line 696
    :cond_59
    const/4 v1, 0x1

    .line 703
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 696
    return v1

    .line 703
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_5e
    nop

    :goto_5f
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 704
    goto :goto_88

    .line 703
    :catchall_63
    move-exception v0

    goto :goto_8e

    .line 700
    :catch_65
    move-exception v0

    .line 701
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_66
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 703
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_5f

    .line 698
    :catch_6f
    move-exception v0

    .line 699
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_86
    .catchall {:try_start_66 .. :try_end_86} :catchall_63

    .line 703
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_5f

    .line 705
    :goto_88
    const-string v0, "resetTouchMode failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 706
    return v3

    .line 703
    :goto_8e
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 704
    throw v0

    :pswitch_data_92
    .packed-switch 0x0
        :pswitch_17
        :pswitch_12
    .end packed-switch
.end method

.method public setEdgeMode(IILjava/util/ArrayList;I)Z
    .registers 13
    .param p1, "touchId"    # I
    .param p2, "mode"    # I
    .param p4, "length"    # I
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(II",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Integer;",
            ">;I)Z"
        }
    .end annotation

    .line 743
    .local p3, "value":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/Integer;>;"
    const-string v0, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v2

    const/4 v3, 0x0

    packed-switch v2, :pswitch_data_9a

    .line 751
    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .local v2, "hidl_reply":Landroid/os/HwParcel;
    goto :goto_18

    .line 747
    .end local v2    # "hidl_reply":Landroid/os/HwParcel;
    :pswitch_12
    invoke-virtual {p0, p2, p3, p4}, Lmiui/util/ITouchFeature;->setEdgeMode(ILjava/util/ArrayList;I)Z

    move-result v0

    return v0

    .line 745
    :pswitch_17
    return v3

    .line 753
    .restart local v2    # "hidl_reply":Landroid/os/HwParcel;
    :goto_18
    :try_start_18
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 754
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_65

    .line 755
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 756
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 757
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 758
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 759
    invoke-virtual {v5, p4}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 760
    invoke-virtual {v5, p3}, Landroid/os/HwParcel;->writeInt32Vector(Ljava/util/ArrayList;)V

    .line 761
    const/16 v0, 0x8

    invoke-interface {v4, v0, v5, v2, v3}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 762
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 763
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 764
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 765
    .local v0, "val":I
    if-eqz v0, :cond_60

    .line 766
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "setEdgeMode failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_5b
    .catch Landroid/os/RemoteException; {:try_start_18 .. :try_end_5b} :catch_76
    .catch Ljava/util/NoSuchElementException; {:try_start_18 .. :try_end_5b} :catch_6c
    .catchall {:try_start_18 .. :try_end_5b} :catchall_6a

    .line 767
    nop

    .line 776
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 767
    return v3

    .line 769
    :cond_60
    const/4 v1, 0x1

    .line 776
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 769
    return v1

    .line 776
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_65
    nop

    :goto_66
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 777
    goto :goto_8f

    .line 776
    :catchall_6a
    move-exception v0

    goto :goto_95

    .line 773
    :catch_6c
    move-exception v0

    .line 774
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_6d
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 776
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_66

    .line 771
    :catch_76
    move-exception v0

    .line 772
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_8d
    .catchall {:try_start_6d .. :try_end_8d} :catchall_6a

    .line 776
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_66

    .line 778
    :goto_8f
    const-string v0, "setEdgeMode failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 779
    return v3

    .line 776
    :goto_95
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 777
    throw v0

    nop

    :pswitch_data_9a
    .packed-switch 0x0
        :pswitch_17
        :pswitch_12
    .end packed-switch
.end method

.method public setEdgeMode(ILjava/util/ArrayList;I)Z
    .registers 12
    .param p1, "mode"    # I
    .param p3, "length"    # I
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Integer;",
            ">;I)Z"
        }
    .end annotation

    .line 711
    .local p2, "value":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/Integer;>;"
    const-string v0, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .line 713
    .local v2, "hidl_reply":Landroid/os/HwParcel;
    const/4 v3, 0x0

    :try_start_a
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 714
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_54

    .line 715
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 716
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 717
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 718
    invoke-virtual {v5, p3}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 719
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32Vector(Ljava/util/ArrayList;)V

    .line 720
    const/16 v0, 0x8

    invoke-interface {v4, v0, v5, v2, v3}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 721
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 722
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 723
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v0

    .line 724
    .local v0, "val":I
    if-eqz v0, :cond_4f

    .line 725
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "setEdgeMode failed. ret = "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v1, v6}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_4a
    .catch Landroid/os/RemoteException; {:try_start_a .. :try_end_4a} :catch_65
    .catch Ljava/util/NoSuchElementException; {:try_start_a .. :try_end_4a} :catch_5b
    .catchall {:try_start_a .. :try_end_4a} :catchall_59

    .line 726
    nop

    .line 735
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 726
    return v3

    .line 728
    :cond_4f
    const/4 v1, 0x1

    .line 735
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 728
    return v1

    .line 735
    .end local v0    # "val":I
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    :cond_54
    nop

    :goto_55
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 736
    goto :goto_7e

    .line 735
    :catchall_59
    move-exception v0

    goto :goto_84

    .line 732
    :catch_5b
    move-exception v0

    .line 733
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_5c
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 735
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_55

    .line 730
    :catch_65
    move-exception v0

    .line 731
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_7c
    .catchall {:try_start_5c .. :try_end_7c} :catchall_59

    .line 735
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_55

    .line 737
    :goto_7e
    const-string v0, "setEdgeMode failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 738
    return v3

    .line 735
    :goto_84
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 736
    throw v0
.end method

.method public setTouchMode(II)Z
    .registers 11
    .param p1, "mode"    # I
    .param p2, "value"    # I

    .line 149
    const-string v0, "vendor.xiaomi.hardware.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .line 151
    .local v2, "hidl_reply":Landroid/os/HwParcel;
    const/4 v3, 0x0

    :try_start_a
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 152
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_50

    .line 153
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 154
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 155
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 156
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 157
    const/4 v0, 0x1

    invoke-interface {v4, v0, v5, v2, v3}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 158
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 159
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 160
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v6

    .line 161
    .local v6, "val":I
    if-eqz v6, :cond_4b

    .line 162
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "setTouchMode failed. ret = "

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_46
    .catch Landroid/os/RemoteException; {:try_start_a .. :try_end_46} :catch_61
    .catch Ljava/util/NoSuchElementException; {:try_start_a .. :try_end_46} :catch_57
    .catchall {:try_start_a .. :try_end_46} :catchall_55

    .line 163
    nop

    .line 172
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 163
    return v3

    .line 165
    :cond_4b
    nop

    .line 172
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 165
    return v0

    .line 172
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    .end local v6    # "val":I
    :cond_50
    nop

    :goto_51
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 173
    goto :goto_7a

    .line 172
    :catchall_55
    move-exception v0

    goto :goto_80

    .line 169
    :catch_57
    move-exception v0

    .line 170
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_58
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 172
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_51

    .line 167
    :catch_61
    move-exception v0

    .line 168
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_78
    .catchall {:try_start_58 .. :try_end_78} :catchall_55

    .line 172
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_51

    .line 174
    :goto_7a
    const-string v0, "setTouchMode failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 175
    return v3

    .line 172
    :goto_80
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 173
    throw v0
.end method

.method public setTouchMode(III)Z
    .registers 12
    .param p1, "touchId"    # I
    .param p2, "mode"    # I
    .param p3, "value"    # I

    .line 186
    const-string v0, "vendor.xiaomi.hw.touchfeature@1.0::ITouchFeature"

    const-string v1, "ITouchFeature"

    invoke-virtual {p0}, Lmiui/util/ITouchFeature;->getSupportTouchFeatureVersion()I

    move-result v2

    const/4 v3, 0x0

    packed-switch v2, :pswitch_data_96

    .line 194
    new-instance v2, Landroid/os/HwParcel;

    invoke-direct {v2}, Landroid/os/HwParcel;-><init>()V

    .local v2, "hidl_reply":Landroid/os/HwParcel;
    goto :goto_18

    .line 190
    .end local v2    # "hidl_reply":Landroid/os/HwParcel;
    :pswitch_12
    invoke-virtual {p0, p2, p3}, Lmiui/util/ITouchFeature;->setTouchMode(II)Z

    move-result v0

    return v0

    .line 188
    :pswitch_17
    return v3

    .line 196
    .restart local v2    # "hidl_reply":Landroid/os/HwParcel;
    :goto_18
    :try_start_18
    const-string v4, "default"

    invoke-static {v0, v4}, Landroid/os/HwBinder;->getService(Ljava/lang/String;Ljava/lang/String;)Landroid/os/IHwBinder;

    move-result-object v4

    .line 197
    .local v4, "hwService":Landroid/os/IHwBinder;
    if-eqz v4, :cond_61

    .line 198
    new-instance v5, Landroid/os/HwParcel;

    invoke-direct {v5}, Landroid/os/HwParcel;-><init>()V

    .line 199
    .local v5, "hidl_request":Landroid/os/HwParcel;
    invoke-virtual {v5, v0}, Landroid/os/HwParcel;->writeInterfaceToken(Ljava/lang/String;)V

    .line 200
    invoke-virtual {v5, p1}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 201
    invoke-virtual {v5, p2}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 202
    invoke-virtual {v5, p3}, Landroid/os/HwParcel;->writeInt32(I)V

    .line 203
    const/4 v0, 0x1

    invoke-interface {v4, v0, v5, v2, v3}, Landroid/os/IHwBinder;->transact(ILandroid/os/HwParcel;Landroid/os/HwParcel;I)V

    .line 204
    invoke-virtual {v2}, Landroid/os/HwParcel;->verifySuccess()V

    .line 205
    invoke-virtual {v5}, Landroid/os/HwParcel;->releaseTemporaryStorage()V

    .line 206
    invoke-virtual {v2}, Landroid/os/HwParcel;->readInt32()I

    move-result v6

    .line 207
    .local v6, "val":I
    if-eqz v6, :cond_5c

    .line 208
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "setTouchMode failed. ret = "

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_57
    .catch Landroid/os/RemoteException; {:try_start_18 .. :try_end_57} :catch_72
    .catch Ljava/util/NoSuchElementException; {:try_start_18 .. :try_end_57} :catch_68
    .catchall {:try_start_18 .. :try_end_57} :catchall_66

    .line 209
    nop

    .line 218
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 209
    return v3

    .line 211
    :cond_5c
    nop

    .line 218
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 211
    return v0

    .line 218
    .end local v4    # "hwService":Landroid/os/IHwBinder;
    .end local v5    # "hidl_request":Landroid/os/HwParcel;
    .end local v6    # "val":I
    :cond_61
    nop

    :goto_62
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 219
    goto :goto_8b

    .line 218
    :catchall_66
    move-exception v0

    goto :goto_91

    .line 215
    :catch_68
    move-exception v0

    .line 216
    .local v0, "e":Ljava/util/NoSuchElementException;
    :try_start_69
    invoke-virtual {v0}, Ljava/util/NoSuchElementException;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 218
    nop

    .end local v0    # "e":Ljava/util/NoSuchElementException;
    goto :goto_62

    .line 213
    :catch_72
    move-exception v0

    .line 214
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "transact failed. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_89
    .catchall {:try_start_69 .. :try_end_89} :catchall_66

    .line 218
    nop

    .end local v0    # "e":Landroid/os/RemoteException;
    goto :goto_62

    .line 220
    :goto_8b
    const-string v0, "setTouchMode failed."

    invoke-static {v1, v0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 221
    return v3

    .line 218
    :goto_91
    invoke-virtual {v2}, Landroid/os/HwParcel;->release()V

    .line 219
    throw v0

    nop

    :pswitch_data_96
    .packed-switch 0x0
        :pswitch_17
        :pswitch_12
    .end packed-switch
.end method

.method public shouldRemoveEdgeSettings()Z
    .registers 2

    .line 134
    iget v0, p0, Lmiui/util/ITouchFeature;->mTouchFeatureProperties:I

    and-int/lit8 v0, v0, 0x40

    if-eqz v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method
