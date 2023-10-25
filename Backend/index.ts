import crypto from 'crypto';
import express, { Application } from 'express';
import http from 'http';
import { Server } from 'socket.io';
import { Client } from 'pg';
import jwt from 'jsonwebtoken';
import { createClient ,GeoReplyWith} from 'redis';
import bodyParser from 'body-parser';
const ACCESS_CODE=crypto.randomBytes(64).toString('hex');
const db = new Client({
  user: 'postgres',
  host: 'postgres',
  database:'Licenta_conturi',
  password: 'test123',
  port: 5432, // default PostgreSQL port
});
db.connect((err) => {
    if (err) {
      console.error('Error connecting to PostgreSQL:', err.stack);
      return;
    }
    console.log('Connected to PostgreSQL');
  });
//db connection
const redisClient =createClient({url: 'redis://redis:6379' });
redisClient.on('connect',(err) => {
    if (err) {
      console.error('Error connecting to Redis:', err);
    } else {
      console.log('Connected to Redis');
    }
});
redisClient.connect();
//redis connection
const port = 8080;
const app: Application = express();
const server: http.Server = http.createServer(app);
const socket: Server=new Server(server);
app.use(bodyParser.json());
app.post('/register',
(req,res) => {
        const credentials:{username:string,password:string}=req.body;
        const query = {
            text: 'SELECT * FROM users WHERE username = $1' ,
            values: [credentials.username],
          };
        
        db.query(query, async (err, qres) => {
            if (err) {
                console.error('Error executing query:', err.stack);
                res.status(500).send({success:false,message:'Error on server side'});
                return;
            }
            if (qres.rows.length === 1) {
                res.status(500).send({success:false,message:'Name already exists'});
                return;
              }
            const query2 = {
              text: 'INSERT INTO users(username,password) VALUES ($1,$2)' ,
              values: [credentials.username,credentials.password],
            };
            db.query(query2,async(err2)=>{
              if (err2) {
                console.error('Error executing query:', err.stack);
                res.status(500).send({success:false,message:'Error on server side'});
                return;
            }
              res.status(200).send({success:true,message:'You were registered'});
              return
            })
           }
        );
      }
  )
app.post('/login',
    (req,res) => {
            const credentials:{username:string,password:string,latitude:string,longitude:string,state:string,message:string}=req.body;
            const query = {
                text: 'SELECT * FROM users WHERE username = $1 AND password = $2' ,
                values: [credentials.username,credentials.password],
              };
            db.query(query, async (err, qres) => {
                if (err) {
                    console.error('Error executing query:', err.stack);
                    res.status(500).send({success:false,message:'Error on server side'});
                    return;
                }
                if (qres.rows.length === 0) {
                    res.status(500).send({success:false,message:'Invalid credentials'});
                    return;
                  }
                const jwtoken=jwt.sign(
                  JSON.stringify([credentials.username,credentials.password]),ACCESS_CODE
                  );
                try{
                  const variable=credentials.username;
                  const redisAdd=await redisClient.hSet(`users:${variable}`,{"username":credentials.username,"state":credentials.state,"message":credentials.message});
                  const redisGeo= await redisClient.geoAdd("locations",{latitude:credentials.latitude,longitude:credentials.longitude,member:credentials.username})
                  if(redisAdd===0 || redisGeo ===0 ){
                    res.status(200).send({success:true,message:'You were logged ,overwritting login',jwtoken:jwtoken});
                    return
                  }
                  else{
                    res.status(200).send({success:true,message:'Successful',jwtoken:jwtoken});
                    return
                  }
                }
                catch(err){
                  console.log("Error on server side")
                  res.status(500).send({success:false,message:'Error on server side'});
                  return
                }
                
            });
          }
      )



socket.on('connection', (socket) => {
  var connectionusername:string=socket.handshake.query.username[0];
  var connectionlatitude:string=socket.handshake.query.latitude[0];
  var connectionlongitude:string=socket.handshake.query.longitude[0];
    jwt.verify(
      socket.handshake.headers['authorization'],
      ACCESS_CODE,
      (err)=>{
      if(err) socket.emit('error', {  message:"You error" });
    })
    socket.on("error", (error) => {
      console.log("Error: " + error);
    });
    console.log("Socket Connected");
    socket.on('update', async (...args) => {
      connectionusername=args[0].username;
      connectionlatitude=args[0].latitude;
      connectionlongitude=args[0].longitude;
      try{
        await redisClient.hSet(`users:${args[0].username}`,["username",args[0].username,"state",args[0].state,"message",args[0].message]);
        await redisClient.geoAdd("locations",{latitude:args[0].latitude,longitude:args[0].longitude,member:args[0].username});
        const redisQuery = await redisClient.geoRadiusWith(
          "locations",
          { latitude: args[0].latitude, longitude: args[0].longitude },
          30,
          "km",
          [GeoReplyWith.COORDINATES]
        );//get users within my range
        if(redisQuery.length===0){
          console.log("Nothing found");
        }
        else{
          if(args[0].state=='danger'){
          for (const elem of redisQuery){
      
            if(elem.member!==args[0].username){
             socket.broadcast.emit(`alarma/${elem.member}`,{latitude:elem.coordinates.latitude,longitude:elem.coordinates.longitude});
            }
          }
          }
          const keys= await redisClient.keys("users*");
          if (keys.length === 0) {
            console.log("Nothing found");
          } 
          else {
            const result=await Promise.all(   
            keys.map(async (key) => {
                return await redisClient.hGetAll(key);
              })
            )
            const concatenatedArray = redisQuery.map((locObj) => {
              const hashObj = result.find((obj) => locObj.member === obj.username);
              return {username:locObj.member,coordinates:locObj.coordinates,state:hashObj.state,message:hashObj.message};
            });
            //get also the user states
            socket.emit(`updateres/${args[0].username}`,concatenatedArray);
        }
        }  
      }
      catch(err){
        console.log("Error on server side")
      }
    });
    socket.on('disconnect', async() => {
      await redisClient.hSet(`users:${connectionusername}`,["username",connectionusername,"state","inactive","message","disconnected"]);
      await redisClient.geoAdd("locations",{latitude:connectionlatitude,longitude:connectionlongitude,member:connectionusername});
      console.log(`${connectionusername} user disconnected`);
    });

});
server.listen(port, () => {
  console.log(`Socket.IO server running at http://localhost:${port}/`);
});

