// SPDX-License-Identifier: Apache-2.0
#include "../Control.h"
#include <cassert>
#include <cerrno>
#include <map>
#include <vector>
struct Fake final : nabu::Backend {
    std::map<std::string,std::string> files{{nabu::kPen,"1\n"},{nabu::kGen2,"0\n"},{nabu::kKeyboard,"0\n"}};
    std::map<std::string,std::string> props;
    std::vector<std::pair<std::string,std::string>> writes;
    bool unplugOnSoc=false;
    bool failWrite=false, failSave=false, ignoreWrite=false;
    int attempts=0, failOnAttempt=-1;
    bool read(const std::string& path,std::string& out) override { auto i=files.find(path);if(i==files.end())return false;out=i->second;if(unplugOnSoc&&path.find("reverse_pen_soc")!=std::string::npos)files[nabu::kChargingMode]="0";return true; }
    bool write(const std::string& path,const std::string& value) override {
        if(++attempts==failOnAttempt||failWrite)return false;writes.emplace_back(path,value);
        if(!ignoreWrite && path!=nabu::kKeyboard)files[path]=value;
        return true;
    }
    std::string property(const std::string& name,const std::string& fallback) override { return props.count(name)?props[name]:fallback; }
    bool save(const std::string& name,const std::string& value) override { if(failSave)return false;props[name]=value;return true; }
};
int main() {
    Fake b;
    auto s=nabu::readState(b);
    assert(s[0]==1 && s[1]==0 && s[2]==1 && s[3]==0 && s[4]==-1 && s[5]==-1);
    assert(nabu::setControl(b,2,0)==0);
    s=nabu::readState(b);assert(s[2]==0 && s[3]==0); // Enable choice is not connection status.
    assert(b.writes.back().second=="disable_keyboard");
    assert(nabu::setControl(b,2,1)==0 && nabu::readState(b)[2]==1 && nabu::readState(b)[3]==0);
    assert(nabu::setControl(b,1,1)==0 && nabu::readState(b)[1]==1);
    assert(nabu::setControl(b,0,0)==0 && nabu::readState(b)[0]==0);
    auto count=b.writes.size();assert(nabu::setControl(b,3,1)==-EINVAL && nabu::setControl(b,0,2)==-EINVAL && b.writes.size()==count);
    b.failSave=true;assert(nabu::setControl(b,0,1)==-EIO && nabu::readState(b)[0]==0 && b.props[nabu::kProps[0]]=="0");
    b.failSave=false;b.ignoreWrite=true;assert(nabu::setControl(b,0,1)==-EIO && b.props[nabu::kProps[0]]=="0");
    b.ignoreWrite=false;b.failWrite=true;assert(nabu::setControl(b,1,0)==-EIO && nabu::readState(b)[1]==1);
    b.failWrite=false;b.files.erase(nabu::kPen);assert(nabu::setControl(b,0,1)==-ENODEV && nabu::readState(b)[0]==-1);
    Fake rollback;
    rollback.failSave=true;rollback.failOnAttempt=2;
    assert(nabu::setControl(rollback,0,0)==-EREMOTEIO && nabu::readState(rollback)[0]==0);
    b.files["/sys/class/power_supply/idt/reverse_pen_soc"]="255\n";
    b.files["/sys/class/power_supply/idt/reverse_iout"]="0\n";
    // Absent state nodes and disabled reverse mode must hide the kernel's 50% fallback.
    s=nabu::readState(b);assert(s[4]==-1 && s[5]==-1);
    b.files[nabu::kChargingMode]="0";b.files[nabu::kChargingState]="4";
    b.files["/sys/class/power_supply/idt/reverse_pen_soc"]="50";
    s=nabu::readState(b);assert(s[4]==-1 && s[5]==-1);
    b.files[nabu::kChargingMode]="1";b.files[nabu::kChargingState]="0";
    assert(nabu::readState(b)[4]==-1); // Searching TX is not a detected receiver.
    b.files[nabu::kChargingState]="4";
    b.files["/sys/class/power_supply/idt/reverse_pen_soc"]="255";
    s=nabu::readState(b);assert(s[4]==-1 && s[5]==0);
    b.files["/sys/class/power_supply/idt/reverse_pen_soc"]="99\n";assert(nabu::readState(b)[4]==99); // No fake 100% conversion.
    b.files["/sys/class/power_supply/idt/reverse_pen_soc"]="50garbage";assert(nabu::readState(b)[4]==-1);
    b.files["/sys/class/power_supply/idt/reverse_pen_soc"]="100";
    assert(nabu::readState(b)[4]==100);
    b.unplugOnSoc=true;assert(nabu::readState(b)[4]==-1);
    b.unplugOnSoc=false;b.files[nabu::kChargingMode]="1";
    for(const char* invalid : {"-1", "6", "4garbage"}) {
        b.files[nabu::kChargingState]=invalid;
        assert(nabu::readState(b)[4]==-1);
        assert(nabu::readPenChargingState(b)[1]==-1);
    }
    b.files[nabu::kChargingState]="5";
    assert(nabu::readState(b)[4]==-1);

}
