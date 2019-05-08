package hello;

import java.util.HashMap;
import java.util.Map;
import org.springframework.boot.SpringApplication;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.context.EnvironmentAware;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@SpringBootApplication
@RestController
public class Application {

	@Autowired
	private Environment env;
	
    @RequestMapping("/")
    public Map<String, String> home() {
        HashMap<String, String> map = new HashMap<>();
		map.put("User", env.getProperty("USER_NAME"));
		map.put("DOB", env.getProperty("D_O_B"));
		map.put("Phone", env.getProperty("PH_NUM"));
		map.put("Mail ID", env.getProperty("MAIL_ID"));
		return map;
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
