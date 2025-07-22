const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting Contract", function () {
  let Voting;
  let voting;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy();
    await voting.deployed();
  });

  it("应该成功创建一个投票主题", async function () {
    const now = Math.floor(Date.now() / 1000);
    const startTime = now - 60;
    const endTime = now + 3600;

    const candidateNames = ["Alice", "Bob"];
    await expect(
      voting.createVoting("Test Vote", "Desc", startTime, endTime, candidateNames)
    )
      .to.emit(voting, "VotingCreated")
      .withArgs(0, "Test Vote", "Desc", startTime, endTime, candidateNames);

    const ids = await voting.getAllThemeIds();
    expect(ids.length).to.equal(1);

    const theme = await voting.getThemeById(0);
    expect(theme.t_name).to.equal("Test Vote");
    expect(theme.t_candidates.length).to.equal(2);
  });

  it("应该允许投票成功", async function () {
    const now = Math.floor(Date.now() / 1000);
    const startTime = now - 60;
    const endTime = now + 3600;

    const candidateNames = ["Alice", "Bob"];
    await voting.createVoting("Test Vote", "Desc", startTime, endTime, candidateNames);

    await expect(voting.connect(addr1).vote(0, 0))
      .to.emit(voting, "Voted")
      .withArgs(addr1.address, 0, 0);

    const result = await voting.getVotingResult(0);
    expect(result[0].c_vote_count).to.equal(1);
    expect(result[1].c_vote_count).to.equal(0);
  });

  it("不应允许在投票开始前投票", async function () {
    const now = Math.floor(Date.now() / 1000);
    const startTime = now + 1000;
    const endTime = now + 3600;

    const candidateNames = ["Alice", "Bob"];
    await voting.createVoting("Future Vote", "Not started", startTime, endTime, candidateNames);

    await expect(voting.connect(addr1).vote(0, 1))
      .to.be.revertedWith("Voting is not started yet");
  });

  it("不应允许在投票结束后投票", async function () {
    const now = Math.floor(Date.now() / 1000);
    const startTime = now - 3600;
    const endTime = now - 60;

    const candidateNames = ["Alice", "Bob"];
    await voting.createVoting("Expired Vote", "Too late", startTime, endTime, candidateNames);

    await expect(voting.connect(addr2).vote(0, 1))
      .to.be.revertedWith("Voting is ended");
  });
});
